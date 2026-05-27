" warmlight.vim — optimised for warm ambient light / night mode (1000-3000K)
" All colours live in the red-yellow-green range; no blues.
" Distinctions come from brightness and red/green channel differences.

set background=dark
hi clear
if exists("syntax_reset")
    syntax reset
endif
let g:colors_name = "warmlight"

" ── Core ─────────────────────────────────────────────────────────────────────
hi Normal        ctermfg=230  ctermbg=NONE cterm=NONE
hi NonText       ctermfg=130  ctermbg=NONE cterm=NONE
hi EndOfBuffer   ctermfg=130  ctermbg=NONE cterm=NONE

" ── Syntax ───────────────────────────────────────────────────────────────────
hi Comment       ctermfg=130  cterm=italic
hi String        ctermfg=148  cterm=NONE
hi Character     ctermfg=148  cterm=NONE
hi Number        ctermfg=222  cterm=NONE
hi Float         ctermfg=222  cterm=NONE
hi Boolean       ctermfg=208  cterm=bold
hi Constant      ctermfg=209  cterm=NONE
hi Identifier    ctermfg=178  cterm=NONE
hi Function      ctermfg=220  cterm=NONE
hi Statement     ctermfg=202  cterm=bold
hi Keyword       ctermfg=208  cterm=bold
hi Conditional   ctermfg=208  cterm=bold
hi Repeat        ctermfg=208  cterm=bold
hi Operator      ctermfg=214  cterm=NONE
hi Exception     ctermfg=196  cterm=bold
hi PreProc       ctermfg=166  cterm=NONE
hi Include       ctermfg=166  cterm=NONE
hi Define        ctermfg=166  cterm=NONE
hi Type          ctermfg=214  cterm=bold
hi StorageClass  ctermfg=214  cterm=NONE
hi Structure     ctermfg=214  cterm=NONE
hi Typedef       ctermfg=214  cterm=NONE
hi Special       ctermfg=209  cterm=NONE
hi SpecialChar   ctermfg=209  cterm=NONE
hi Tag           ctermfg=220  cterm=NONE
hi Delimiter     ctermfg=230  cterm=NONE
hi SpecialComment ctermfg=172 cterm=italic
hi Underlined    ctermfg=220  cterm=underline
hi Error         ctermfg=196  ctermbg=52  cterm=bold
hi Todo          ctermfg=208  ctermbg=NONE cterm=bold,reverse

" ── Editor chrome ────────────────────────────────────────────────────────────
hi LineNr        ctermfg=130  ctermbg=NONE cterm=NONE
hi CursorLineNr  ctermfg=220  ctermbg=NONE cterm=bold
hi CursorLine    ctermfg=NONE ctermbg=236  cterm=NONE
hi CursorColumn  ctermfg=NONE ctermbg=236  cterm=NONE
hi ColorColumn   ctermfg=NONE ctermbg=52   cterm=NONE
hi SignColumn    ctermfg=130  ctermbg=NONE cterm=NONE
hi VertSplit     ctermfg=130  ctermbg=NONE cterm=NONE
hi Folded        ctermfg=130  ctermbg=236  cterm=NONE
hi FoldColumn    ctermfg=130  ctermbg=NONE cterm=NONE

" ── Status / Tab line ────────────────────────────────────────────────────────
hi StatusLine    ctermfg=0    ctermbg=214  cterm=bold
hi StatusLineNC  ctermfg=130  ctermbg=234  cterm=NONE
hi TabLine       ctermfg=130  ctermbg=234  cterm=NONE
hi TabLineSel    ctermfg=0    ctermbg=214  cterm=bold
hi TabLineFill   ctermfg=NONE ctermbg=234  cterm=NONE

" ── Search / Selection ───────────────────────────────────────────────────────
hi Search        ctermfg=0    ctermbg=214  cterm=NONE
hi IncSearch     ctermfg=0    ctermbg=220  cterm=bold
hi Visual        ctermfg=NONE ctermbg=58   cterm=NONE
hi VisualNOS     ctermfg=NONE ctermbg=58   cterm=NONE

" ── Popup / Completion ───────────────────────────────────────────────────────
hi Pmenu         ctermfg=220  ctermbg=234  cterm=NONE
hi PmenuSel      ctermfg=0    ctermbg=214  cterm=bold
hi PmenuSbar     ctermfg=NONE ctermbg=236  cterm=NONE
hi PmenuThumb    ctermfg=NONE ctermbg=214  cterm=NONE
hi WildMenu      ctermfg=0    ctermbg=214  cterm=bold

" ── Messages ─────────────────────────────────────────────────────────────────
hi ErrorMsg      ctermfg=196  ctermbg=NONE cterm=bold
hi WarningMsg    ctermfg=208  ctermbg=NONE cterm=bold
hi ModeMsg       ctermfg=220  ctermbg=NONE cterm=bold
hi MoreMsg       ctermfg=148  ctermbg=NONE cterm=bold
hi Question      ctermfg=148  ctermbg=NONE cterm=bold

" ── Diff ─────────────────────────────────────────────────────────────────────
hi DiffAdd       ctermfg=148  ctermbg=22   cterm=NONE
hi DiffChange    ctermfg=214  ctermbg=58   cterm=NONE
hi DiffDelete    ctermfg=196  ctermbg=52   cterm=NONE
hi DiffText      ctermfg=220  ctermbg=58   cterm=bold

" ── Misc ─────────────────────────────────────────────────────────────────────
hi MatchParen    ctermfg=0    ctermbg=214  cterm=bold
hi SpellBad      ctermfg=196  ctermbg=NONE cterm=underline
hi SpellCap      ctermfg=208  ctermbg=NONE cterm=underline
hi Directory     ctermfg=220  ctermbg=NONE cterm=bold
hi Title         ctermfg=214  ctermbg=NONE cterm=bold
