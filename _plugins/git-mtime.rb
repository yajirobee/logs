module Jekyll
    module GitMtime
        class GitError < StandardError; end

        def self.get_mtime(path)
            `git ls-files --error-unmatch #{path} 2> /dev/null`
            return nil if ($? != 0) # not tracked by git

            git_log_str = `git log -1 --format=format:"%ct" -- #{path}`
            raise GitError, "git log failed" if ($? != 0 || git_log_str.empty?)

            return Time.at git_log_str.to_i
        end
    end

    Hooks.register(:pages, :post_init, priority: Hooks::PRIORITY_MAP[:low]) do |page|
        # set mtime to the time of the last commit related to the current page
        page.data['mtime'] = GitMtime.get_mtime(page.path)
    end
end