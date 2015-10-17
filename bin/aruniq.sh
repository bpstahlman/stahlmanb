#! /bin/bash

declare aruniq_version="1.1"
declare -a names

# Save the command line equivalent for display
cmdline="'$0'"
for arg in "$@"; do
	cmdline="$cmdline '$arg'"
done

while getopts ":n:s:x:t:" opt; do
	case $opt in
		n)
		names[${#names[@]}]=$OPTARG
		;;
		s)
		# TODO-validation
		declare -x opt_size=$OPTARG
		;;
		x)
		# Save name of file containing previously archived files
		opt_xfile=$OPTARG
		;;
		t)
		# Validate tag (must be single identifier)
		opt_tag=$OPTARG
		if ! [ $(echo $opt_tag|sed -n '/^[[:alnum:]_]\+$/p; q') ]; then
			echo 1>&2 "Bad tag specified with -t option" \
				"(only alnum and underscores allowed): $opt_tag"
			exit 1
		fi
		;;
		\?)
		echo 1>&2 "Bad option: $OPTARG"
		exit 1
		;;
		:)
		echo 1>&2 "Option missing arg: $OPTARG"
		exit 1
		;;
	esac
done

shift $((OPTIND - 1))

# Construct the -iname predicates for find command
for name in "${names[@]}"; do
	namepred="${namepred:+ $namepred -o} -iname '$name'"
done
# If no file patterns were specified, need to use -type f to prevent find from
# finding directories and such.
if [ -z "$namepred" ] ; then
	namepred=" -type f "
fi
# filename | pathname | bytes | last status change
eval find '"$@"' ' \( ' "$namepred" ' \) ' -printf "'%f|%p|%s|%C@\n'" >archraw.lst
#eval find '"$@"' ${namepred:+" \( $namepred \) "} \
#	-printf "'%f|%p|%s|%C@\n'" >archraw.lst

# If no files were found, we're done.
if (( ! $(wc archraw.lst|awk '{print $2}') )); then
	echo "No files matching name pattern were found."
	exit 0
fi

# We're not necessarily past point of no return. (If -x option was specified,
# we need to remove files that also appear in the specified `exclude' file.)

# The following vars are needed in the doubly-nested while pipeline below
declare -xi tarfile_num=0
declare -x date=$(date +%d%b%Y_%H-%M-%S)

# Copy tar into the current directory, so we can save it to the backup media
# along with archive files.
tarprog=$(which tar)
# Send stderr to /dev/null to avoid warning about tar already existing when
# this script has been run before...
cp $tarprog ./ 2>/dev/null
# Strip leading path
tarprog=${tarprog##*/}

#set -o verbose
#set -o xtrace
IFS='|'

# Use xargs and md5sum to generate a 128-bit checksum for each file. Quote the
# filenames (xargs permits single or double quotes) to protect embedded
# whitespace.
# filename | pathname | bytes | last status change | md5sum
cut -d\| -f2 archraw.lst | sed 's/\([^[:space:]]\)\(.*[^[:space:]]\)\?/"\1\2"/' |
xargs md5sum | cut -d ' ' -f1 |
# Use paste to append the checksum to the other fields (`-' represents stdin)
paste -d\| archraw.lst - | tee archsum.lst |
# If exclude file was specified, use it to filter already archived files out
# of list. Pass exclude file first, then new list of files on stdin, with a
# variable allowing the awk script to distinguish between them.
# (Alternatively, could check FILENAME.)
# IMPORTANT NOTE: Despite claiming to support extended RE's, awk doesn't
# support ranges (\{n,m\}).
if [ -n "$opt_xfile" ]; then
	awk -F\| '
		!checking_new && /^[^\|]+(\|[^\|]+)(\|[^\|]+)(\|[^\|]+)(\|[^\|]+)$/ {
			key = $1 "|" $3 "|" $5;
			filenames[key] = 1
		}
		checking_new {
			key = $1 "|" $3 "|" $5;
			if (key in filenames) {
				# duplicate
				print $0 >"archold.lst";
			} else {
				print $0
			}
		}
	' "$opt_xfile" checking_new=1 -
else
	# Is this necessary?
	cat
fi >archnew.lst


# If no new files were found, we're done.
if (( ! $(wc archnew.lst|awk '{print $2}') )); then
	echo "No new files matching name pattern were found."
	exit 0
fi

# Sort the files so that groups of duplicates (as determined by name, size,
# and checksum) are together and sorted according to last status change
# (oldest first).
# Design choice: I use last status change as one of the keys to ensure that
# when there are duplicates, the "original" will be preserved.
# Note: 09Aug2009: It appears that since writing this script, `find' added the
# fractional portion to the %C@ printf format specifier. It doesn't appear to
# matter, though, since `sort's numeric sort can handle fixed point decimal.
sort -t\| -k1,1b -k3,3bn -k5,5b -k4,4bn archnew.lst | tee archsort.lst |
# Write the "unique" file (i.e., the first in a group) to STDOUT, and the
# duplicates to archdups.lst
awk -F\| '{
	key = $1 "|" $3 "|" $5;
	if (key in filenames) {
		# duplicate
		print $0 >"archdups.lst";
	} else {
		# original
		filenames[key] = 1
		print $0
	}
}' |
# Design choice: For aesthetic reasons, sort on full pathname before
# finalizing the order in which files will be passed to tar. (Note that this
# sort must occur after the one done prior to the exclusion of duplicates
# above.)
sort -t\| -k2,2 | tee ${opt_tag-aruniq}_${date}.lst |
# NOTE: Used to strip no longer needed, redundant first field; however,
# filtering against the exclude file is easier if we leave it.
# file | pathname | bytes | last status change | md5sum
#cut -d\| -f2- | tee archuniq.lst |
# Use awk to put a blank line at the beginning and end of every 'chunk'.
# (Note: This means there will be 2 consecutive blanks between chunks. This is
# necessary because of the way the nested while loops are structured.)
# pathname | bytes
awk -F\| "
	BEGIN { nbmax = ${opt_size-0} }"'
	nbmax == 0 {
		# Chunk size does not apply
		print $2
	}
	nbmax > 0 {
		nb = $3
		if (nbt == 0 || (nbt + nb) > nbmax) {
			# Starting first or new chunk
			print ""
			if (nbt > 0) {
				# This is not the first chunk, so extra blank line is needed
				print ""
			}
			if (nb > nbmax) {
				# Warn that chunk size is exceeded
				print "-"
			}
			# Print 1st file in new chunk and set nbt accordingly
			print $2
			nbt = nb
		} else {
			print $2
			nbt += nb
		}
	}
' |
# Loop over all files
while read blank_line; do
	let tarfile_num++
	# Create a file to hold list of input files for tar.
	#exec 7>archtar.lst
	while read pathname && [ -n "$pathname" ]; do
		if [ "$pathname" = '-' ]; then
			# Set flag to warn next time through when we know the filename
			warn_size=1
		elif [ $warn_size ]; then
			warn_size=
			# Warn that this file is being skipped
			echo >&2 "$0: Cannot add file $pathname" \
				"without exceeding specified tar file size limit."
		else
			# Output full pathname for tar
			echo $pathname
		fi
	done |
	# Create a tar file containing only the unique files
	# Note: Could create a gzipped tar file, but for pictures, it doesn't save
	# much...
	# TODO - Remove -v ?
	# Note: I've noticed that when an archive small is very small relative to
	# the one created just before it, its modification time can be earlier
	# than the one built afterward. For this reason, I've changed `ls -ltr' to
	# `ls -l' later in the script, to ensure that archive files are ordered
	# according to the number embedded in the name.
	tar -cvf ${opt_tag-aruniq}_${date}_$tarfile_num.tar -T- >/dev/null
done

# Cleanup
shopt -s extglob
unset IFS
# Put a readme file in the directory
cat <<EOF >README_${opt_tag-aruniq}_${date}
************************************ README ************************************
This file was generated automatically by ${0##*/} to document the creation of
archive files. ${0##*/} was written by Brett Pershing Stahlman on or around
January 2007. It is invoked as follows:

${0##*/} [-s SIZE] [-x FILE] [-n PAT1 ... -n PATN] [-t TAG] DIR1 [DIR2] ...

Synopsis: ${0##*/} recursively searches the directories given on the command
line, looking for files that match one of the case-insensitive glob patterns
given with the -n option. ${0##*/} then uses a file checksum to guarantee that
there are no duplicate files in this list. (Duplicate files have the same
filename and checksum, but are located in different directories.  Digital
camera software packages tend to generate multiple duplicate files.) When
duplicates are found, ${0##*/} considers only the oldest file in the list.
Additionally, the user may specify an \`exclude file' with the -x option. The
exclude file contains entries of the following form:

file | pathname | bytes | last status change | md5sum

This is the same format contained in the file <tag>_<date>.lst, which is
produced by this script to document what files were archived. If it is desired
to prevent the same files from being archived again the next time ${0##*/} is
run, simply append <tag>_<date>.lst to a master file every time an archive is
performed, and specify this master file with the -x option each time the
script is run. (Note that lines in the exclude file that do not conform to the
format shown above are ignored, so it is possible to insert a date and/or a
comment before each group of files in the master exclude file.)

Example: (after running ${0##*/} to perform archival)

	echo \$(date)|cat - ${opt_tag-aruniq}_${date}.lst >>aruniq_master.lst

Finally, ${0##*/} uses \`tar' to package the files into archives. If the -s
option is used, ${0##*/} limits the total size of the files in a single
archive to SIZE bytes. (Note that the byte total compared with SIZE is the
summation of file byte counts as determined by the %s specifier to find's
printf command, not the size of the archive file; thus, if you plan to
post-process the archive file(s) with a compression utility, you may wish to
consider not only the capacity of your backup media (e.g., CD or zip drive),
but also the expected compression ratio when choosing the SIZE option.) If the
-t TAG option is used, ${0##*/} will use the specified tag to create output
filenames that are more meaningful than the default, which consists of some
generic text and a time/date stamp.

********************************************************************************

Version of ${0##*/}: $aruniq_version

Invocation: ${0##*/} was invoked with a command line that was
functionally equivalent to (but probably not identical to) the following:

	$cmdline

Archives created:
$(ls -1tr ${opt_tag-aruniq}_${date}_[1-9]*([0-9]).tar|sed 's/^/'$'\t''/')

List file: (see notes on exclude file option above)
	${opt_tag-aruniq}_${date}.lst

Creation times:
	Start: $(echo $date|sed '
		s/\([0-9]\)\([[:alpha:]]\)/\1 \2/;
		s/\([[:alpha:]]\)\([0-9]\)/\1 \2/;
		s/_/ /; s/-/:/g'
	)
	End:   $(date '+%d %b %Y %H:%M:%S')

The following version of tar was used (located in the current directory):
$(tar --version|sed -n 1p)

To extract archive contents...
	Move to the directory where files should be extracted and type...

	tar -xvf <archive_file>

	(Note that <archive_file> represents the name of one of the .tar files
	listed above.)

Here is the list of files contained in the archives:
$(
ix=1
for file in $(ls -1 ${opt_tag-aruniq}_${date}_[1-9]*([0-9]).tar); do
	echo
	echo "*** Archive #$ix ***"
	echo "Name: $file"
	echo "Size: $(find $file -printf '%s') bytes"
	echo "Contains:"
	tar -tf "$file"|sed 's/^/'$'\t''/'
	ix=$((ix+1))
done
)

EOF


# If any files was created
echo "Done."



#	vim:ts=4:sw=4:tw=78:ft=sh
