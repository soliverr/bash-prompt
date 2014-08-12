
Summary: Sets bash's PS1 & PROMPT_COMMAND variables
Summary(ru_RU.UTF-8): Установить переменные PS1 и PROMPT_COMMAND для BASH
Name: bash-prompt
Version: 2.1
Release: 2
License: GPL
Group: System Environment/Shells
Source: %{name}-%{version}.tar.gz
URL: http://www.ertelecom.ru
BuildRoot: %{_tmppath}/%{name}-%{version}
BuildArch: noarch

%description
This package contains two sripts to set PS1 and PROMPT_COMMAND bash's variables.
This two variables can be configured through bash-prompt.config file for users and
groups. PROMPT_COMMAND variable can set the escape characters so that KONSOLE tabs 
get set dynamically.

%description -l ru_RU.UTF-8
Устанавливаются переменные BASH PS1 и PROMPT_COMMAND для группы или отдельного 
пользователя. Переменные конфигурируются чере файл конфигурации bash-prompt.config.
Так же устанавливается escape-последовательность для динамического формирования
закладки в терминале KONSOLE.

%prep

%setup -q

%build

%install
rm -rf %{buildroot}
%{__install} -d %{buildroot}/etc/sysconfig
%{__install} -d %{buildroot}/etc/profile.d
%{__install} -m 0755 bash-prompt %{buildroot}/etc/sysconfig/bash-prompt-xterm
%{__install} -m 0755 bash-ps1 %{buildroot}/etc/profile.d/bash-ps1.sh
%{__install} -m 0644 bash-prompt.config %{buildroot}/etc/sysconfig/bash-prompt.config

%{__sed} --in-place -e 's#config=bash-prompt.config#config=/etc/sysconfig/bash-prompt.config#' %{buildroot}/etc/sysconfig/bash-prompt-xterm
%{__sed} --in-place -e 's#config=bash-prompt.config#config=/etc/sysconfig/bash-prompt.config#' %{buildroot}/etc/profile.d/bash-ps1.sh

%clean
rm -rf %{buildroot}

%files
%defattr(-, root, root)
%doc README
%doc COPYING
%config /etc/sysconfig/bash-prompt-xterm
%config /etc/sysconfig/bash-prompt.config
/etc/profile.d/bash-ps1.sh

%changelog
* Tue Aug 12 2014 Kryazhevskikh Sergey <soliverr@gmail.com> 2.1-2  17:27:40 +0600
- New upstream release

* Tue Oct 30 2012 Kryazhevskikh Sergey <soliverr@gmail.com> 2.1-1  10:36:56 +0600
- Added preinst script for smooth upgrade

* Fri Oct 26 2012 Kryazhevskikh Sergey <soliverr@gmail.com> 2.0-2  12:44:21 +0600
- New upstream version

* Wed Dec 01 2010 Kryazhevskikh Sergey <soliverr@gmail.com> 1.0-7  17:56:14 +0500
- New upstream version

* Thu Jun 10 2010 Kryazhevskikh Sergey <soliverr@gmail.com> 1.0-6  13:15:55 +0600
- New upstream version

* Wed Dec 16 2009 Kryazhevskikh Sergey <soliverr@gmail.com> 1.0-5  12:03:29
- New upstream version

* Wed Aug 05 2009 Kryazhevskikh Sergey <soliverr@gmail.com> 1.0-4  18:47:54
- New upstream version

* Mon Sep 10 2008 Kryaczevskih Sergey <soliverr@gmail.com>
- Minor bugs fixed

* Mon Sep 09 2008 Kryaczevskih Sergey <soliverr@gmail.com>
- Initial release
