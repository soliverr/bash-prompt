#! /bin/bash
#
# Control script for Bash-Prompt variables: Ps1 and PROMPT_COMMAND
#
config=/etc/default/bash-ps1

usage () {

	cat << __EOFF__
 Usage:
   $0 {--set | --unset} [NAME]
   $0 {--enable | --disable} [--group] [NAME]
   $0 {--enable | --disable} system

 Control usage of Bash-Prompt variables: PS1 and PROMPT_COMMAND

 Arguments:
   set [NAME]      - Set variables for current user session. Current variables 
                     are backuped.
   unset           - Restore backuped variables for current user session.

   enable [NAME]   - Enable using Bash-Prompt variables in user .bashrc file.
                     Current variables are backuped in .bashrc file.
   disable [NAME]  - Disable using Bash-Prompt variables in user .bashrc file.
                     Variables are restored in .bashrc file.

   NAME            - user name. If --group is specified, NAME is a group name.                
				     Default is current user.

   enable | disable system - Enable or disable setting Bash-Prompt variables
                             in system bashrc file and skeleton files.
                             You should be superuser.
__EOFF__
}

# Args: $1 - action $2 - name
process_user () {
    local hm nm ps

    nm="`echo $2 | tr [:lower:] [:upper:]`"

    case "$1" in
        --set)
            [ -n "$BACKUP_PS1" ] && return
            echo "export BACKUP_PS1=\$PS1;"
            echo "export BACKUP_PROMPT_COMMAND=\$PROMPT_COMMAND;"
            # Set variables in current session
            source $config
            # Get variable content for given user name
            ps=`set | sed -ne "s/USER_${nm}_PS1='\(.*\)'/\1/p" | head -1`
            echo "PS1=`echo \'$ps\'`;"
            #echo "PROMPT_COMMAND=/etc/default/bash-prompt;"
        ;;
        --unset)
            [ -z "$BACKUP_PS1" ] && return
            echo "PS1=\$BACKUP_PS1;"
            #echo "PROMPT_COMMAND=\$BACKUP_PROMPT_COMMAND;"
            echo "unset BACKUP_PS1 BACKUP_PROMPT_COMMAND;"
        ;;
        --enable | --disable)
            hm="`getent passwd $2 | cut -d ':' -f 6`"
            [ -z "$hm" ] && return
            if [ "$1" = "--enable" ] ; then
                sed --in-place -e 's/^\(\s*\)\(PS1=.*\)/\1BASH_PROMPT_\2/' -e 's/^\(\s\+\)\(PROMPT_COMMAND=.*\)/\1BASH_PROMPT_\2/' $hm/{.bashrc,.profile,.bash_profile} 2>&-
            else
                sed --in-place -e 's/^\(\s*\)BASH_PROMPT_\(PS1=.*\)/\1\2/' -e 's/^\(\s\+\)BASH_PROMPT_\(PROMPT_COMMAND=.*\)/\1\2/' $hm/{.bashrc,.profile,.bash_profile} 2>&-
            fi
        ;;
    esac
}

# Args: $1 - action $2 - name
process_group () {
    local nm

    nm="`echo $2 | tr [:lower:] [:upper:]`"

    case "$1" in
        --set)
            [ -n "$BACKUP_PS1" ] && return
            echo "export BACKUP_PS1=\$PS1;"
            echo "export BACKUP_PROMPT_COMMAND=\$PROMPT_COMMAND;"
            # Set variables in current session
            source $config
            # Get variable content for given user name
            ps=`set | sed -ne "s/GROUP_${nm}_PS1='\(.*\)'/\1/p" | head -1`
            echo "PS1=`echo \'$ps\'`;"
            #echo "PROMPT_COMMAND=/etc/default/bash-prompt;"
        ;;
        --unset)
            [ -z "$BACKUP_PS1" ] && return
            echo "PS1=\$BACKUP_PS1;"
            #echo "PROMPT_COMMAND=\$BACKUP_PROMPT_COMMAND;"
            echo "unset BACKUP_PS1 BACKUP_PROMPT_COMMAND;"
        ;;
        --enable | --disable)
	        for i in `getent group $2 | sed -e 's/^.*:\(.*\)/\1/' -e 's/,/\n/g'` ; do
		        process_user $1 $i
	        done
        ;;
    esac
}

# Args: $1 - action
process_system () {
    if [ "$1" = "--enable" ] ; then
        sed --in-place -e 's/^\(\s*\)\(PS1=.*\)/\1BASH_PROMPT_\2/' -e 's/^\(\s\+\)\(PROMPT_COMMAND=.*\)/\1BASH_PROMPT_\2/' /etc/bash.bashrc /etc/skel/{.bashrc,.profile} 2>&-
    else
        sed --in-place -e 's/^\(\s*\)BASH_PROMPT_\(PS1=.*\)/\1\2/' -e 's/^\(\s\+\)BASH_PROMPT_\(PROMPT_COMMAND=.*\)/\1\2/' /etc/bash.bashrc /etc/skel/{.bashrc,.profile} 2>&-
    fi
}

#
# Process command line arguments
#
for i in "$@" ; do
	if [ $i = "--set" -o $i = "--unset" -o $i = "--enable" -o $i = "--disable" ]; then
		action=$i
	elif [ $i = "--help" ]; then
		usage
		exit 0
	elif [ $i = "--group" ]; then
		do_group=1
	else
		actor=$i
	fi
done

if [ -z "$do_group" -a -z "$actor" ] ; then
	actor=`whoami`
fi

if [ -z "$action" -o -z "$actor" ] ; then
	usage
	exit 1
fi

rc=1

if [ $actor = "system" ] ; then
	process_system $action
	rc=$?
elif [ -n "$do_group" ] ; then
	process_group $action $actor
	rc=$?
else
	process_user $action $actor
	rc=$?
fi

exit $rc


