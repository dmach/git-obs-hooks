Name:           git-obs-hooks
Version:        0.1.0
Release:        0
Summary:        Framework for running git hooks in git-obs and osc
License:        GPL-2.0-or-later
Group:          Development/Tools/Other
URL:            https://github.com/dmach/git-obs-hooks
Source:         https://github.com/dmach/git-obs-hooks/archive/refs/tags/%{version}.tar.gz#/%{name}-%{version}.tar.gz

BuildRequires:  fdupes
BuildArch:      noarch
BuildRoot:      %{_tmppath}/%{name}-%{version}-build

%define hook_dir %{_datadir}/git-obs-hooks

%description
Framework for running git hooks in git-obs and osc.

To install the hooks on the system, place executables under:
 - %{hook_dir}/<git-hook>.d/<filename>
 - ~/.local/share/git-obs-hooks/<git-hook>.d/<filename>
To enable git-obs-hooks in the current git repo, run: install-git-obs-hooks

See githooks(5) man page for more help on the hooks.

%package script-convert-changes
Summary: working script for %{name} converting last record of *.changes to git commit
Requires: %{name} = %{version}

%description script-convert-changes
Working script for %{name}, which causes `git commit` to generate
default commit message based on the last last record in the
`*.changes`.

%prep
%autosetup -p1

%build
:

%install
install -D install-git-obs-hooks %{buildroot}%{_bindir}/install-git-obs-hooks

install -d %{buildroot}%{hook_dir}/applypatch-msg.d
install -D git-obs-hook-template %{buildroot}%{hook_dir}/applypatch-msg

install -d %{buildroot}%{hook_dir}/commit-msg.d
install -D git-obs-hook-template %{buildroot}%{hook_dir}/commit-msg

install -d %{buildroot}%{hook_dir}/fsmonitor-watchman.d
install -D git-obs-hook-template %{buildroot}%{hook_dir}/fsmonitor-watchman

install -d %{buildroot}%{hook_dir}/post-update.d
install -D git-obs-hook-template %{buildroot}%{hook_dir}/post-update

install -d %{buildroot}%{hook_dir}/pre-applypatch.d
install -D git-obs-hook-template %{buildroot}%{hook_dir}/pre-applypatch

install -d %{buildroot}%{hook_dir}/pre-commit.d
install -D git-obs-hook-template %{buildroot}%{hook_dir}/pre-commit

install -d %{buildroot}%{hook_dir}/pre-merge-commit.d
install -D git-obs-hook-template %{buildroot}%{hook_dir}/pre-merge-commit

install -d %{buildroot}%{hook_dir}/prepare-commit-msg.d
install -D git-obs-hook-template %{buildroot}%{hook_dir}/prepare-commit-msg

install -d %{buildroot}%{hook_dir}/pre-push.d
install -D git-obs-hook-template %{buildroot}%{hook_dir}/pre-push

install -d %{buildroot}%{hook_dir}/pre-rebase.d
install -D git-obs-hook-template %{buildroot}%{hook_dir}/pre-rebase

install -d %{buildroot}%{hook_dir}/pre-receive.d
install -D git-obs-hook-template %{buildroot}%{hook_dir}/pre-receive

install -d %{buildroot}%{hook_dir}/push-to-checkout.d
install -D git-obs-hook-template %{buildroot}%{hook_dir}/push-to-checkout

install -d %{buildroot}%{hook_dir}/sendemail-validate.d
install -D git-obs-hook-template %{buildroot}%{hook_dir}/sendemail-validate

install -d %{buildroot}%{hook_dir}/update.d
install -D git-obs-hook-template %{buildroot}%{hook_dir}/update

for scriptlet in scripts/*/*.sh ; do
    cp -p "${scriptlet}" "%{buildroot}%{hook_dir}/${scriptlet#*/}"
done

%fdupes %{buildroot}%{hook_dir}

%files
%defattr(-,root,root,-)
%attr(0755, root, root) %{_bindir}/install-git-obs-hooks
%dir %{hook_dir}
%dir %{hook_dir}/*.d
%attr(0755, root, root) %{hook_dir}/applypatch-msg
%attr(0755, root, root) %{hook_dir}/commit-msg
%attr(0755, root, root) %{hook_dir}/fsmonitor-watchman
%attr(0755, root, root) %{hook_dir}/post-update
%attr(0755, root, root) %{hook_dir}/pre-applypatch
%attr(0755, root, root) %{hook_dir}/pre-commit
%attr(0755, root, root) %{hook_dir}/pre-merge-commit
%attr(0755, root, root) %{hook_dir}/prepare-commit-msg
%attr(0755, root, root) %{hook_dir}/pre-push
%attr(0755, root, root) %{hook_dir}/pre-rebase
%attr(0755, root, root) %{hook_dir}/pre-receive
%attr(0755, root, root) %{hook_dir}/push-to-checkout
%attr(0755, root, root) %{hook_dir}/sendemail-validate
%attr(0755, root, root) %{hook_dir}/update
%license LICENSE
%doc README.md

%files script-convert-changes
%{hook_dir}/prepare-commit-msg.d

%changelog
