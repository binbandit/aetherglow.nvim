" AetherGlow color scheme for Vim
" Maintainer: binbandit
" License: MIT

lua << EOF
package.loaded['aetherglow'] = nil
package.loaded['aetherglow.init'] = nil
require('aetherglow').setup()
EOF