%Get the most updated versions of the "origin" branches. This is what has
%been pushed
!git fetch
%Rebuild your unpushed commits as though you had started working with the
%most updated version.  This is basically in place of a git merge.  You can
%still end up with conflicts if you changed a file that was changed since
%the commit you actually build off.
!git rebase master