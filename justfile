# ┌───────────────────────────────────────────────────────────────────┐
# │                   Resume Builder with Typst                       │
# │ ───────────────────────────────────────────────────────────────── │
# │ Commands: just build, just pdf, just html, just clean             │
# └───────────────────────────────────────────────────────────────────┘

# Variables
output_dir := "output"
data_dir := "data"
templates_dir := "templates"
css_file := "assets/styles-html.css"

# Default recipe - show help
default:
    @just --list

# ─────────────────────────────────────────────────────────────────────
# Main Build Targets
# ─────────────────────────────────────────────────────────────────────

# Build everything (validate + PDFs + HTMLs)
all: validate build

# Build all outputs (PDFs + HTMLs)
build: setup pdf html
    @echo "✓ All builds completed"

# Create output directories
setup:
    @mkdir -p {{output_dir}}/en {{output_dir}}/ptbr

# ─────────────────────────────────────────────────────────────────────
# PDF Generation
# ─────────────────────────────────────────────────────────────────────

# Generate all PDFs
pdf: pdf-en pdf-ptbr

# Generate English PDFs (full + onepage)
pdf-en: setup
    @echo "Building English PDFs..."
    typst compile --root . --input lang=en {{templates_dir}}/resume-full.typ {{output_dir}}/en/resume.pdf
    typst compile --root . --input lang=en {{templates_dir}}/resume-onepage.typ {{output_dir}}/en/resume-onepage.pdf
    @echo "✓ Created {{output_dir}}/en/resume.pdf"
    @echo "✓ Created {{output_dir}}/en/resume-onepage.pdf"

# Generate Portuguese PDFs (full + onepage)
pdf-ptbr: setup
    @echo "Building Portuguese PDFs..."
    typst compile --root . --input lang=pt {{templates_dir}}/resume-full.typ {{output_dir}}/ptbr/resume.pdf
    typst compile --root . --input lang=pt {{templates_dir}}/resume-onepage.typ {{output_dir}}/ptbr/resume-onepage.pdf
    @echo "✓ Created {{output_dir}}/ptbr/resume.pdf"
    @echo "✓ Created {{output_dir}}/ptbr/resume-onepage.pdf"

# ─────────────────────────────────────────────────────────────────────
# HTML Generation
# ─────────────────────────────────────────────────────────────────────

# Generate all HTML files
html: html-en html-ptbr copy-assets

# Generate English HTML resume
html-en: setup
    @echo "Building English HTML..."
    typst compile --root . --input lang=en --features html --format html {{templates_dir}}/resume-html.typ {{output_dir}}/en/index.html
    @just _inject-html en
    @echo "✓ Created {{output_dir}}/en/index.html"

# Generate Portuguese HTML resume
html-ptbr: setup
    @echo "Building Portuguese HTML..."
    typst compile --root . --input lang=pt --features html --format html {{templates_dir}}/resume-html.typ {{output_dir}}/ptbr/index.html
    @just _inject-html ptbr
    @echo "✓ Created {{output_dir}}/ptbr/index.html"

# Internal: Inject CSS, scripts, and meta tags into HTML
_inject-html lang:
    #!/usr/bin/env python3
    lang = "{{lang}}"
    css_file = "{{css_file}}"
    output_dir = "{{output_dir}}"
    
    css = open(css_file).read()
    toc_js = open('assets/toc-spy.js').read()
    html_file = f'{output_dir}/{lang}/index.html'
    html = open(html_file).read()
    
    favicon_links = '<link rel="icon" type="image/svg+xml" href="../favicon.svg"><link rel="icon" type="image/x-icon" href="../favicon.ico"><link rel="apple-touch-icon" href="../apple-touch-icon.png"><link rel="manifest" href="../site.webmanifest">'
    
    nerdfont_cdn = '<style>@font-face{font-family:"Symbols Nerd Font";src:url("https://cdn.jsdelivr.net/gh/ryanoasis/nerd-fonts@v3.3.0/patched-fonts/NerdFontsSymbolsOnly/SymbolsNerdFontMono-Regular.ttf") format("truetype");font-weight:normal;font-style:normal;font-display:swap;}.nf{font-family:"Symbols Nerd Font",monospace;}</style>'
    
    tailwind_script = '<script src="https://cdn.tailwindcss.com"></script><script>tailwind.config={darkMode:"class"}</script>'
    
    theme_script = '<script>function toggleTheme(){document.documentElement.classList.toggle("dark");localStorage.setItem("theme",document.documentElement.classList.contains("dark")?"dark":"light")}(function(){const t=localStorage.getItem("theme")||"light";if(t==="dark")document.documentElement.classList.add("dark")})()</script>'
    
    # SEO meta tags per language
    seo_meta = {
        'en': '<meta name="description" content="Platform Engineer with 10+ years of experience. CNCF Kubestronaut. Specialized in IDP, DevEx, and Cloud Native technologies."><meta name="keywords" content="Platform Engineer, Kubernetes, DevOps, Cloud Native, CNCF, Kubestronaut, IDP, DevEx"><meta name="author" content="Fabio Luciano"><meta property="og:type" content="profile"><meta property="og:title" content="Fabio Luciano - Platform Engineer"><meta property="og:description" content="Platform Engineer | CNCF Kubestronaut | DevEx Specialist"><meta name="twitter:card" content="summary">',
        'ptbr': '<meta name="description" content="Platform Engineer com mais de 10 anos de experiência. CNCF Kubestronaut. Especializado em IDP, DevEx e tecnologias Cloud Native."><meta name="keywords" content="Platform Engineer, Kubernetes, DevOps, Cloud Native, CNCF, Kubestronaut, IDP, DevEx"><meta name="author" content="Fabio Luciano"><meta property="og:type" content="profile"><meta property="og:title" content="Fabio Luciano - Platform Engineer"><meta property="og:description" content="Platform Engineer | CNCF Kubestronaut | DevEx Specialist"><meta name="twitter:card" content="summary">'
    }
    
    body_classes = 'max-w-4xl mx-auto p-8 bg-white dark:bg-slate-900 text-slate-900 dark:text-slate-100 font-sans antialiased transition-colors duration-300'
    
    head_inject = ''.join([
        favicon_links,
        seo_meta.get(lang, ''),
        nerdfont_cdn,
        tailwind_script,
        theme_script,
        '<style>' + css + '</style>',
    ])
    
    # Inject TOC script before closing body tag
    toc_script_tag = '<script>' + toc_js + '</script>'
    
    html = html.replace('</head>', head_inject + '</head>')
    html = html.replace('<body>', f'<body class="{body_classes}">')
    html = html.replace('</body>', toc_script_tag + '</body>')
    
    open(html_file, 'w').write(html)

# ─────────────────────────────────────────────────────────────────────
# Assets
# ─────────────────────────────────────────────────────────────────────

# Copy all assets to output
copy-assets: copy-photo copy-favicons

# Copy photo to output
copy-photo: setup
    @[ -f {{data_dir}}/photo.jpg ] && cp {{data_dir}}/photo.jpg {{output_dir}}/photo.jpg || true

# Copy favicons to output
copy-favicons: setup
    @[ -d assets ] && cp assets/favicon.* assets/apple-touch-icon.png assets/site.webmanifest {{output_dir}}/ || true

# Copy data files (for web access)
copy-data: setup
    cp {{data_dir}}/common.yaml {{output_dir}}/common.yaml
    cp {{data_dir}}/resume.en.yaml {{output_dir}}/en/resume.yaml
    cp {{data_dir}}/resume.ptbr.yaml {{output_dir}}/ptbr/resume.yaml
    @just copy-photo
    @echo "✓ Data files copied"

# ─────────────────────────────────────────────────────────────────────
# Validation
# ─────────────────────────────────────────────────────────────────────

# Validate all YAML files against JSON Resume schema
validate:
    @echo "Validating resume files..."
    python3 scripts/validate_resume.py --all

# Validate English resume only
validate-en:
    python3 scripts/validate_resume.py {{data_dir}}/resume.en.yaml

# Validate Portuguese resume only
validate-ptbr:
    python3 scripts/validate_resume.py {{data_dir}}/resume.ptbr.yaml

# Install validation dependencies
install-validator-deps:
    pip3 install jsonschema PyYAML
    @echo "✓ Validation dependencies installed"

# ─────────────────────────────────────────────────────────────────────
# Development
# ─────────────────────────────────────────────────────────────────────

# Watch for changes and rebuild English PDF
watch:
    typst watch --root . {{templates_dir}}/resume-full.typ {{output_dir}}/en/resume.pdf

# Watch for changes and rebuild Portuguese PDF
watch-ptbr:
    typst watch --root . {{templates_dir}}/resume-full.typ {{output_dir}}/ptbr/resume.pdf

# Start local server for HTML preview
serve: html
    @echo "Starting server at http://localhost:8000"
    cd {{output_dir}} && python3 -m http.server 8000

# Open English HTML in browser
open-html:
    open {{output_dir}}/en/index.html

# Open English PDF in Preview
open-pdf:
    open {{output_dir}}/en/resume.pdf

# ─────────────────────────────────────────────────────────────────────
# Utilities
# ─────────────────────────────────────────────────────────────────────

# Remove all generated files
clean:
    @echo "Cleaning output directory..."
    rm -rf {{output_dir}}/*
    @echo "✓ Cleaned"

# Install Typst (macOS)
install-typst:
    brew install typst
    @echo "✓ Typst installed"

# Install Just (macOS)
install-just:
    brew install just
    @echo "✓ Just installed"

# Build for release (clean + build + copy data)
release: clean build copy-data
    @echo "✓ Release build completed"
    @echo ""
    @echo "Output files:"
    @find {{output_dir}} -type f | sort

# Show project info
info:
    @echo "Resume Builder"
    @echo "─────────────────────────────"
    @echo "Output:    {{output_dir}}"
    @echo "Templates: {{templates_dir}}"
    @echo "Data:      {{data_dir}}"
    @echo ""
    @typst --version
