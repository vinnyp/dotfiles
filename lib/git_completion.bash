 --ignore-unmatch --quiet"
		return
		;;
	esac

	__git_complete_index_file "--cached"
}

_git_shortlog ()
{
	__git_has_doubledash && return

	case "$cur" in
	--*)
		__gitcomp "
			$__git_log_common_options
			$__git_log_shortlog_options
			--numbered --summary
			"
		return
		;;
	esac
	__git_complete_revlist
}

_git_show ()
{
	__git_has_doubledash && return

	case "$cur" in
	--pretty=*|--format=*)
		__gitcomp "$__git_log_pretty_formats $(__git_pretty_aliases)
			" "" "${cur#*=}"
		return
		;;
	--diff-algorithm=*)
		__gitcomp "$__git_diff_algorithms" "" "${cur##--diff-algorithm=}"
		return
		;;
	--*)
		__gitcomp "--pretty= --format= --abbrev-commit --oneline
			--show-signature
			$__git_diff_common_options
			"
		return
		;;
	esac
	__git_complete_revlist_file
}

_git_show_branch ()
{
	case "$cur" in
	--*)
		__gitcomp "
			--all --remotes --topo-order --current --more=
			--list --independent --merge-base --no-name
			--color --no-color
			--sha1-name --sparse --topics --reflog
			"
		return
		;;
	esac
	__git_complete_revlist
}

_git_stash ()
{
	local save_opts='--keep-index --no-keep-index --quiet --patch'
	local subcommands='save list show apply clear drop pop create branch'
	local subcommand="$(__git_find_on_cmdline "$subcommands")"
	if [ -z "$subcommand" ]; then
		case "$cur" in
		--*)
			__gitcomp "$save_opts"
			;;
		*)
			if [ -z "$(__git_find_on_cmdline "$save_opts")" ]; then
				__gitcomp "$subcommands"
			fi
			;;
		esac
	else
		case "$subcommand,$cur" in
		save,--*)
			__gitcomp "$save_opts"
			;;
		apply,--*|pop,--*)
			__gitcomp "--index --quiet"
			;;
		show,--*|drop,--*|branch,--*)
			;;
		show,*|apply,*|drop,*|pop,*|branch,*)
			__gitcomp_nl "$(git --git-dir="$(__gitdir)" stash list \
					| sed -n -e 's/:.*//p')"
			;;
		*)
			;;
		esac
	fi
}

_git_submodule ()
{
	__git_has_doubledash && return

	local subcommands="add status init deinit update summary foreach sync"
	if [ -z "$(__git_find_on_cmdline "$subcommands")" ]; then
		case "$cur" in
		--*)
			__gitcomp "--quiet --cached"
			;;
		*)
			__gitcomp "$subcommands"
			;;
		esac
		return
	fi
}

_git_svn ()
{
	local subcommands="
		init fetch clone rebase dcommit log find-rev
		set-tree commit-diff info create-ignore propget
		proplist show-ignore show-externals branch tag blame
		migrate mkdirs reset gc
		"
	local subcommand="$(__git_find_on_cmdline "$subcommands")"
	if [ -z "$subcommand" ]; then
		__gitcomp "$subcommands"
	else
		local remote_opts="--username= --config-dir= --no-auth-cache"
		local fc_opts="
			--follow-parent --authors-file= --repack=
			--no-metadata --use-svm-props --use-svnsync-props
			--log-window-size= --no-checkout --quiet
			--repack-flags --use-log-author --localtime
			--ignore-paths= --include-paths= $remote_opts
			"
		local init_opts="
			--template= --shared= --trunk= --tags=
			--branches= --stdlayout --minimize-url
			--no-metadata --use-svm-props --use-svnsync-props
			--rewrite-root= --prefix= --use-log-author
			--add-author-from $remote_opts
			"
		local cmt_opts="
			--edit --rmdir --find-copies-harder --copy-similarity=
			"

		case "$subcommand,$cur" in
		fetch,--*)
			__gitcomp "--revision= --fetch-all $fc_opts"
			;;
		clone,--*)
			__gitcomp "--revision= $fc_opts $init_opts"
			;;
		init,--*)
			__gitcomp "$init_opts"
			;;
		dcommit,--*)
			__gitcomp "
				--merge --strategy= --verbose --dry-run
				--fetch-all --no-rebase --commit-url
				--revision --interactive $cmt_opts $fc_opts
				"
			;;
		set-tree,--*)
			__gitcomp "--stdin $cmt_opts $fc_opts"
			;;
		create-ignore,--*|propget,--*|proplist,--*|show-ignore,--*|\
		show-externals,--*|mkdirs,--*)
			__gitcomp "--revision="
			;;
		log,--*)
			__gitcomp "
				--limit= --revision= --verbose --incremental
				--oneline --show-commit --non-recursive
				--authors-file= --color
				"
			;;
		rebase,--*)
			__gitcomp "
				--merge --verbose --strategy= --local
				--fetch-all --dry-run $fc_opts
				"
			;;
		commit-diff,--*)
			__gitcomp "--message= --file= --revision= $cmt_opts"
			;;
		info,--*)
			__gitcomp "--url"
			;;
		branch,--*)
			__gitcomp "--dry-run --message --tag"
			;;
		tag,--*)
			__gitcomp "--dry-run --message"
			;;
		blame,--*)
			__gitcomp "--git-format"
			;;
		migrate,--*)
			__gitcomp "
				--config-dir= --ignore-paths= --minimize
				--no-auth-cache --username=
				"
			;;
		reset,--*)
			__gitcomp "--revision= --parent"
			;;
		*)
			;;
		esac
	fi
}

_git_tag ()
{
	local i c=1 f=0
	while [ $c -lt $cword ]; do
		i="${words[c]}"
		case "$i" in
		-d|-v)
			__gitcomp_nl "$(__git_tags)"
			return
			;;
		-f)
			f=1
			;;
		esac
		((c++))
	done

	case "$prev" in
	-m|-F)
		;;
	-*|tag)
		if [ $f = 1 ]; then
			__gitcomp_nl "$(__git_tags)"
		fi
		;;
	*)
		__gitcomp_nl "$(__git_refs)"
		;;
	esac

	case "$cur" in
	--*)
		__gitcomp "
			--list --delete --verify --annotate --message --file
			--sign --cleanup --local-user --force --column --sort
			--contains --points-at
			"
		;;
	esac
}

_git_whatchanged ()
{
	_git_log
}

__git_main ()
{
	local i c=1 command __git_dir

	while [ $c -lt $cword ]; do
		i="${words[c]}"
		case "$i" in
		--git-dir=*) __git_dir="${i#--git-dir=}" ;;
		--git-dir)   ((c++)) ; __git_dir="${words[c]}" ;;
		--bare)      __git_dir="." ;;
		--help) command="help"; break ;;
		-c|--work-tree|--namespace) ((c++)) ;;
		-*) ;;
		*) command="$i"; break ;;
		esac
		((c++))
	done

	if [ -z "$command" ]; then
		case "$cur" in
		--*)   __gitcomp "
			--paginate
			--no-pager
			--git-dir=
			--bare
			--version
			--exec-path
			--exec-path=
			--html-path
			--man-path
			--info-path
			--work-tree=
			--namespace=
			--no-replace-objects
			--help
			"
			;;
		*)     __git_compute_porcelain_commands
		       __gitcomp "$__git_porcelain_commands $(__git_aliases)" ;;
		esac
		return
	fi

	local completion_func="_git_${command//-/_}"
	declare -f $completion_func >/dev/null && $completion_func && return

	local expansion=$(__git_aliased_command "$command")
	if [ -n "$expansion" ]; then
		words[1]=$expansion
		completion_func="_git_${expansion//-/_}"
		declare -f $completion_func >/dev/null && $completion_func
	fi
}

__gitk_main ()
{
	__git_has_doubledash && return

	local g="$(__gitdir)"
	local merge=""
	if [ -f "$g/MERGE_HEAD" ]; then
		merge="--merge"
	fi
	case "$cur" in
	--*)
		__gitcomp "
			$__git_log_common_options
			$__git_log_gitk_options
			$merge
			"
		return
		;;
	esac
	__git_complete_revlist
}

if [[ -n ${ZSH_VERSION-} ]]; then
	echo "WARNING: this script is deprecated, please see git-completion.zsh" 1>&2

	autoload -U +X compinit && compinit

	__gitcomp ()
	{
		emulate -L zsh

		local cur_="${3-$cur}"

		case "$cur_" in
		--*=)
			;;
		*)
			local c IFS=$' \t\n'
			local -a array
			for c in ${=1}; do
				c="$c${4-}"
				case $c in
				--*=*|*.) ;;
				*) c="$c " ;;
				esac
				array[${#array[@]}+1]="$c"
			done
			compset -P '*[=:]'
			compadd -Q -S '' -p "${2-}" -a -- array && _ret=0
			;;
		esac
	}

	__gitcomp_nl ()
	{
		emulate -L zsh

		local IFS=$'\n'
		compset -P '*[=:]'
		compadd -Q -S "${4- }" -p "${2-}" -- ${=1} && _ret=0
	}

	__gitcomp_file ()
	{
		emulate -L zsh

		local IFS=$'\n'
		compset -P '*[=:]'
		compadd -Q -p "${2-}" -f -- ${=1} && _ret=0
	}

	_git ()
	{
		local _ret=1 cur cword prev
		cur=${words[CURRENT]}
		prev=${words[CURRENT-1]}
		let cword=CURRENT-1
		emulate ksh -c __${service}_main
		let _ret && _default && _ret=0
		return _ret
	}

	compdef _git git gitk
	return
fi

__git_func_wrap ()
{
	local cur words cword prev
	_get_comp_words_by_ref -n =: cur words cword prev
	$1
}

# Setup completion for certain functions defined above by setting common
# variables and workarounds.
# This is NOT a public function; use at your own risk.
__git_complete ()
{
	local wrapper="__git_wrap${2}"
	eval "$wrapper () { __git_func_wrap $2 ; }"
	complete -o bashdefault -o default -o nospace -F $wrapper $1 2>/dev/null \
		|| complete -o default -o nospace -F $wrapper $1
}

# wrapper for backwards compatibility
_git ()
{
	__git_wrap__git_main
}

# wrapper for backwards compatibility
_gitk ()
{
	__git_wrap__gitk_main
}

__git_complete git __git_main
__git_complete gitk __gitk_main

# The following are necessary only for Cygwin, and only are needed
# when the user has tab-completed the executable name and consequently
# included the '.exe' suffix.
#
if [ Cygwin = "$(uname -o 2>/dev/null)" ]; then
__git_complete git.exe __git_main
fi