#!/bin/sh
#
# CLANG 3.8 is installed on Ubuntu 16.04 by default. If user wants to use
# newer version, he should make use of update-alternatives to switch.
# At here, the script file switch CLANG to 5.0.
#
update-alternatives --install /usr/bin/clang clang /usr/bin/clang-5.0 100
update-alternatives --install /usr/bin/clang clang /usr/bin/clang-3.9 60
update-alternatives --install /usr/bin/clang clang /usr/bin/clang-3.8 50
update-alternatives --install /usr/bin/clang++ clang++ /usr/bin/clang++-5.0 100
update-alternatives --install /usr/bin/clang++ clang++ /usr/bin/clang++-3.9 60
update-alternatives --install /usr/bin/clang++ clang++ /usr/bin/clang++-3.8 50
update-alternatives --install /usr/bin/clang-apply-replacements clang-apply-replacements /usr/bin/clang-apply-replacements-5.0 100
update-alternatives --install /usr/bin/clang-apply-replacements clang-apply-replacements /usr/bin/clang-apply-replacements-3.9 60
update-alternatives --install /usr/bin/clang-apply-replacements clang-apply-replacements /usr/bin/clang-apply-replacements-3.8 50
update-alternatives --install /usr/bin/clang-check clang-check /usr/bin/clang-check-5.0 100
update-alternatives --install /usr/bin/clang-check clang-check /usr/bin/clang-check-3.9 60
update-alternatives --install /usr/bin/clang-check clang-check /usr/bin/clang-check-3.8 50
#update-alternatives --install /usr/bin/clang-cl clang-cl /usr/bin/clang-cl-5.0 100
#update-alternatives --install /usr/bin/clang-cl clang-cl /usr/bin/clang-cl-3.9 60
#update-alternatives --install /usr/bin/clang-cl clang-cl /usr/bin/clang-cl-3.8 50
update-alternatives --install /usr/bin/clang-query clang-query /usr/bin/clang-query-5.0 100
update-alternatives --install /usr/bin/clang-query clang-query /usr/bin/clang-query-3.9 60
update-alternatives --install /usr/bin/clang-query clang-query /usr/bin/clang-query-3.8 50
#update-alternatives --install /usr/bin/clang-tblgen clang-tblgen /usr/bin/clang-tblgen-3.9 60
#update-alternatives --install /usr/bin/clang-tblgen clang-tblgen /usr/bin/clang-tblgen-3.8 50
update-alternatives --install /usr/bin/llvm-ar llvm-ar /usr/bin/llvm-ar-5.0 100
update-alternatives --install /usr/bin/llvm-ar llvm-ar /usr/bin/llvm-ar-3.9 60
update-alternatives --install /usr/bin/llvm-ar llvm-ar /usr/bin/llvm-ar-3.8 50
update-alternatives --install /usr/bin/llvm-as llvm-as /usr/bin/llvm-as-5.0 100
update-alternatives --install /usr/bin/llvm-as llvm-as /usr/bin/llvm-as-3.9 60
update-alternatives --install /usr/bin/llvm-as llvm-as /usr/bin/llvm-as-3.8 50
update-alternatives --install /usr/bin/llvm-bcanalyzer llvm-bcanalyzer /usr/bin/llvm-bcanalyzer-5.0 100
update-alternatives --install /usr/bin/llvm-bcanalyzer llvm-bcanalyzer /usr/bin/llvm-bcanalyzer-3.9 60
update-alternatives --install /usr/bin/llvm-bcanalyzer llvm-bcanalyzer /usr/bin/llvm-bcanalyzer-3.8 50
update-alternatives --install /usr/bin/llvm-config llvm-config /usr/bin/llvm-config-5.0 100
update-alternatives --install /usr/bin/llvm-config llvm-config /usr/bin/llvm-config-3.9 60
update-alternatives --install /usr/bin/llvm-config llvm-config /usr/bin/llvm-config-3.8 50
update-alternatives --install /usr/bin/llvm-cov llvm-cov /usr/bin/llvm-cov-5.0 100
update-alternatives --install /usr/bin/llvm-cov llvm-cov /usr/bin/llvm-cov-3.9 60
update-alternatives --install /usr/bin/llvm-cov llvm-cov /usr/bin/llvm-cov-3.8 50
update-alternatives --install /usr/bin/llvm-diff llvm-diff /usr/bin/llvm-diff-5.0 100
update-alternatives --install /usr/bin/llvm-diff llvm-diff /usr/bin/llvm-diff-3.9 60
update-alternatives --install /usr/bin/llvm-diff llvm-diff /usr/bin/llvm-diff-3.8 50
update-alternatives --install /usr/bin/llvm-dis llvm-dis /usr/bin/llvm-dis-5.0 100
update-alternatives --install /usr/bin/llvm-dis llvm-dis /usr/bin/llvm-dis-3.9 60
update-alternatives --install /usr/bin/llvm-dis llvm-dis /usr/bin/llvm-dis-3.8 50
update-alternatives --install /usr/bin/llvm-dwarfdump llvm-dwarfdump /usr/bin/llvm-dwarfdump-5.0 100
update-alternatives --install /usr/bin/llvm-dwarfdump llvm-dwarfdump /usr/bin/llvm-dwarfdump-3.9 60
update-alternatives --install /usr/bin/llvm-dwarfdump llvm-dwarfdump /usr/bin/llvm-dwarfdump-3.8 50
update-alternatives --install /usr/bin/llvm-extract llvm-extract /usr/bin/llvm-extract-5.0 100
update-alternatives --install /usr/bin/llvm-extract llvm-extract /usr/bin/llvm-extract-3.9 60
update-alternatives --install /usr/bin/llvm-extract llvm-extract /usr/bin/llvm-extract-3.8 50
update-alternatives --install /usr/bin/llvm-link llvm-link /usr/bin/llvm-link-5.0 100
update-alternatives --install /usr/bin/llvm-link llvm-link /usr/bin/llvm-link-3.9 60
update-alternatives --install /usr/bin/llvm-link llvm-link /usr/bin/llvm-link-3.8 50
update-alternatives --install /usr/bin/llvm-mc llvm-mc /usr/bin/llvm-mc-5.0 100
update-alternatives --install /usr/bin/llvm-mc llvm-mc /usr/bin/llvm-mc-3.9 60
update-alternatives --install /usr/bin/llvm-mc llvm-mc /usr/bin/llvm-mc-3.8 50
update-alternatives --install /usr/bin/llvm-nm llvm-nm /usr/bin/llvm-nm-5.0 100
update-alternatives --install /usr/bin/llvm-nm llvm-nm /usr/bin/llvm-nm-3.9 60
update-alternatives --install /usr/bin/llvm-nm llvm-nm /usr/bin/llvm-nm-3.8 50
update-alternatives --install /usr/bin/llvm-objdump llvm-objdump /usr/bin/llvm-objdump-5.0 100
update-alternatives --install /usr/bin/llvm-objdump llvm-objdump /usr/bin/llvm-objdump-3.9 60
update-alternatives --install /usr/bin/llvm-objdump llvm-objdump /usr/bin/llvm-objdump-3.8 50
update-alternatives --install /usr/bin/llvm-ranlib llvm-ranlib /usr/bin/llvm-ranlib-5.0 100
update-alternatives --install /usr/bin/llvm-ranlib llvm-ranlib /usr/bin/llvm-ranlib-3.9 60
update-alternatives --install /usr/bin/llvm-ranlib llvm-ranlib /usr/bin/llvm-ranlib-3.8 50
update-alternatives --install /usr/bin/llvm-rtdyld llvm-rtdyld /usr/bin/llvm-rtdyld-5.0 100
update-alternatives --install /usr/bin/llvm-rtdyld llvm-rtdyld /usr/bin/llvm-rtdyld-3.9 60
update-alternatives --install /usr/bin/llvm-rtdyld llvm-rtdyld /usr/bin/llvm-rtdyld-3.8 50
update-alternatives --install /usr/bin/llvm-size llvm-size /usr/bin/llvm-size-5.0 100
update-alternatives --install /usr/bin/llvm-size llvm-size /usr/bin/llvm-size-3.9 60
update-alternatives --install /usr/bin/llvm-size llvm-size /usr/bin/llvm-size-3.8 50
update-alternatives --install /usr/bin/llvm-tblgen llvm-tblgen /usr/bin/llvm-tblgen-5.0 100
update-alternatives --install /usr/bin/llvm-tblgen llvm-tblgen /usr/bin/llvm-tblgen-3.9 60
update-alternatives --install /usr/bin/llvm-tblgen llvm-tblgen /usr/bin/llvm-tblgen-3.8 50
update-alternatives --install /usr/bin/lld lld /usr/bin/lld-5.0 100
update-alternatives --install /usr/bin/ld.lld ld.lld /usr/bin/ld.lld-5.0 100

update-alternatives --set clang /usr/bin/clang-5.0
update-alternatives --set clang++ /usr/bin/clang++-5.0
update-alternatives --set clang-apply-replacements /usr/bin/clang-apply-replacements-5.0
update-alternatives --set clang-check /usr/bin/clang-check-5.0
update-alternatives --set clang-query /usr/bin/clang-query-5.0
#update-alternatives --set clang-tblgen /usr/bin/clang-tblgen-5.0
update-alternatives --set llvm-ar /usr/bin/llvm-ar-5.0
update-alternatives --set llvm-as /usr/bin/llvm-as-5.0
update-alternatives --set llvm-bcanalyzer /usr/bin/llvm-bcanalyzer-5.0
update-alternatives --set llvm-config /usr/bin/llvm-config-5.0
update-alternatives --set llvm-cov /usr/bin/llvm-cov-5.0
update-alternatives --set llvm-diff /usr/bin/llvm-diff-5.0
update-alternatives --set llvm-dis /usr/bin/llvm-dis-5.0
update-alternatives --set llvm-dwarfdump /usr/bin/llvm-dwarfdump-5.0
update-alternatives --set llvm-extract /usr/bin/llvm-extract-5.0
update-alternatives --set llvm-link /usr/bin/llvm-link-5.0
update-alternatives --set llvm-mc /usr/bin/llvm-mc-5.0
update-alternatives --set llvm-nm /usr/bin/llvm-nm-5.0
update-alternatives --set llvm-objdump /usr/bin/llvm-objdump-5.0
update-alternatives --set llvm-ranlib /usr/bin/llvm-ranlib-5.0
update-alternatives --set llvm-rtdyld /usr/bin/llvm-rtdyld-5.0
update-alternatives --set llvm-size /usr/bin/llvm-size-5.0
update-alternatives --set llvm-tblgen /usr/bin/llvm-tblgen-5.0
update-alternatives --set lld /usr/bin/lld-5.0
update-alternatives --set ld.lld /usr/bin/ld.lld-5.0
