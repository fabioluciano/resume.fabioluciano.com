// Header Component
// Unified header with variant support for full and onepage templates
// Usage: #import "components/header.typ": header-full, header-onepage
// Theme: Vibrante (matching fabioluciano.com blog)

#import "../design.typ": *
#import "../i18n.typ": t

// ═══════════════════════════════════════════════════════════════════════════════
// HEADER - FULL VARIANT
// ═══════════════════════════════════════════════════════════════════════════════

#let header-full(data, lang: "en") = {
  // Clean phone number for tel: links (remove spaces and parentheses)
  let clean-phone = data.basics.phone.replace(" ", "").replace("(", "").replace(")", "")

  block(width: 100%, above: 0pt, below: 0.4em)[
    // Name and label (centered)
    #align(center)[
      #text(size: size-name-full, weight: "bold", fill: color-primary, tracking: tracking-wide)[#data.basics.name]
      #v(-2em)
      #text(size: size-label-full, fill: color-text, weight: "medium", tracking: tracking-tight)[#data.basics.label]
    ]
    #v(0.4em)

    // Photo + Contact info + Social (3 equal columns)
    #box(
      width: 100%,
      fill: color-bg-light,
      radius: radius-large,
      inset: inset-header-full,
    )[
      #grid(
        columns: (1fr, 1fr, 1fr),
        gutter: 0pt,
        align: (center + horizon, left + horizon, left + horizon),
        // Photo (left) with vibrante border
        [
          #if data.basics.at("image", default: none) != none {
            profile-photo("/data/" + data.basics.image, size: 80pt)
          }
        ],
        // Contact info (center) with left and right borders
        [
          #box(inset: (x: 16pt), stroke: (left: stroke-normal + color-divider, right: stroke-normal + color-divider))[
            #text(size: size-small-full, weight: "bold", fill: color-primary)[#t("contact", lang)]
            #v(0.6em)
            #text(size: size-date-full, fill: color-muted)[
              #link("mailto:" + data.basics.email)[#nf-icon(icon-email, size: size-date-full, color: color-muted) #data.basics.email]
              #linebreak()
              #link("tel:" + clean-phone)[#nf-icon(icon-phone, size: size-date-full, color: color-muted) #data.basics.phone]
              #linebreak()
              #nf-icon(icon-location, size: size-date-full, color: color-muted) #data.basics.location.city, #data.basics.location.region
              #linebreak()
              #link(data.basics.url)[#nf-icon(icon-website, size: size-date-full, color: color-muted) Website]
            ]
          ]
        ],
        // Social links (right)
        [
          #box(inset: (left: 16pt))[
            #text(size: size-small-full, weight: "bold", fill: color-primary)[#t("social", lang)]
            #v(0.3em)
            #text(size: size-date-full)[
              #for profile in data.basics.profiles [
                #nf-icon(get-social-icon(profile.network), size: size-date-full, color: color-primary) #link(profile.url)[#text(fill: color-primary)[#profile.network]]
                #linebreak()
              ]
            ]
          ]
        ]
      )
    ]
  ]
}

// ═══════════════════════════════════════════════════════════════════════════════
// HEADER - ONEPAGE VARIANT
// ═══════════════════════════════════════════════════════════════════════════════

#let header-onepage(data, lang: "en") = {
  // Clean phone number for tel: links (remove spaces and parentheses)
  let clean-phone = data.basics.phone.replace(" ", "").replace("(", "").replace(")", "")
  let header-columns = (auto, 1fr, 2fr, 1fr)

  block(width: 100%, fill: color-header-bg, radius: radius-large, inset: inset-header-onepage, below: 0.4em)[
    #grid(
      columns: header-columns,
      align: (center + horizon, left + horizon, center + horizon, right + horizon),
      gutter: inset-card,
      [
        // Profile photo
        #if data.basics.at("image", default: none) != none {
          profile-photo-small("/data/" + data.basics.image, size: 40pt)
        }
      ],
      [
        #text(size: size-small-onepage, fill: color-header-text, weight: "bold")[
          #nf-icon(icon-email, size: size-small-onepage, color: color-header-text) #data.basics.email
          #v(-0.3em)
          #link("tel:" + clean-phone)[#nf-icon(icon-phone, size: size-small-onepage, color: color-header-text) #data.basics.phone]
          #v(-0.3em)
          #nf-icon(icon-location, size: size-small-onepage, color: color-header-text) #data.basics.location.city
        ]
      ],
      [
        #text(size: size-name-onepage, weight: "bold", fill: white, tracking: tracking-normal)[#data.basics.name]
        #v(-1.8em)
        #text(size: size-label-onepage, fill: white, weight: "medium")[#data.basics.label]
      ],
      [
        #text(size: size-small-onepage, fill: color-header-text, weight: "bold")[
          #let profile-links = data.basics.profiles.map(p => [
            #nf-icon(get-social-icon(p.network), size: size-small-onepage, color: color-header-text) #h(0.2em) #link(p.url)[#p.network]
          ])
          #profile-links.join(" │ ")
          #v(-0.3em)
          #link(data.basics.url)[#nf-icon(icon-website, size: size-small-onepage, color: color-header-text) #h(0.2em) #data.basics.url]
        ]
      ]
    )
  ]
}
