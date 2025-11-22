# SPEC file overview:
# https://docs.fedoraproject.org/en-US/quick-docs/creating-rpm-packages/#con_rpm-spec-file-overview
# Fedora packaging guidelines:
# https://docs.fedoraproject.org/en-US/packaging-guidelines/

Name: bootupd8r
Version: 1
Release: 1%{?dist}
Summary: Updates boot loaders

License: GPLv3
URL:     https://github.com/marta-lewandowska/bootupd8r

BuildRequires: git
BuildRequires: make

Source0: bootupd8r-%{version}.tar.xz

# For %%_userunitdir and %%systemd_* macros
BuildRequires:  systemd-rpm-macros

BuildArch: noarch

%{?systemd_requires}

%description
bootupd8r creates a fallback mechanism on UEFI for installing new boot loaders.

%prep
%autosetup -S git_am

%install
install -m 0755 -d %{buildroot}%{_prefix}/lib/bootloader
install -m 0755 -t %{buildroot}%{_prefix}/lib/bootloader install_bootloader
install -m 0755 -d %{buildroot}%{_sbindir}
install -m 0755 -t %{buildroot}%{_sbindir} create_boot_path
install -m 0755 -t %{buildroot}%{_sbindir} set_boot_entry
install -m 0755 -d %{buildroot}%{_unitdir}
install -m 0755 -t %{buildroot}%{_unitdir} AB-boot.service
install -m 0755 -d %{buildroot}%{_unitdir}/multi-user.target.wants
ln -s ../AB-boot.service %{buildroot}%{_unitdir}/multi-user.target.wants

%files
%defattr(-,root,root,-)
%dir %{_prefix}/lib/bootloader
%{_prefix}/lib/bootloader/install_bootloader
%{_sbindir}/set_boot_entry
%{_sbindir}/create_boot_path
%{_unitdir}/multi-user.target.wants
%{_unitdir}/AB-boot.service

%posttrans
. %{_sbindir}/create_boot_path

%changelog
* Fri Nov 21 2025 Pavel Valena <pvalena@redhat.com>
- Fixes to Makefile and spec file

* Fri Nov 14 2025 Marta Lewandowska <mlewando@redhat.com>
- First trial of bootupdr
