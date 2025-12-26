function aurpush -a commit_msg
    # Check if commit message provided
    if test -z "$commit_msg"
        echo "Usage: aurpush <commit message>"
        return 1
    end
    
    # Update .SRCINFO
    makepkg --printsrcinfo > .SRCINFO
    if test $status -ne 0
        echo "Error: makepkg failed"
        return 1
    end
    
    # Git add all
    git add .
    
    # Commit with message
    git commit -m "$commit_msg"
    if test $status -ne 0
        echo "Error: git commit failed"
        return 1
    end
    
    # Push to AUR
    git push
end

