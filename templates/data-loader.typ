// Data loader utility for merging YAML files
// This function loads common.yaml and merges with language-specific YAML
// Open/Closed: Adding new languages only requires creating new YAML files

// Language code mapping for file naming conventions
#let lang-file-map = (
  en: "en",
  pt: "ptbr",
  ptbr: "ptbr",
)

// Simple dictionary merge (no arrays, for items inside arrays)
#let merge-item(target, source) = {
  let result = target
  for (key, value) in source {
    result.insert(key, value)
  }
  result
}

// Merge arrays by index - combines common array with language-specific translations
#let merge-arrays(common-array, lang-array) = {
  if common-array == none { return lang-array }
  if lang-array == none { return common-array }
  
  let result = ()
  let max-len = calc.max(common-array.len(), lang-array.len())
  
  for i in range(max-len) {
    let common-item = if i < common-array.len() { common-array.at(i) } else { (:) }
    let lang-item = if i < lang-array.len() { lang-array.at(i) } else { (:) }
    
    if type(common-item) == dictionary and type(lang-item) == dictionary {
      result.push(merge-item(common-item, lang-item))
    } else if lang-item != none {
      result.push(lang-item)
    } else {
      result.push(common-item)
    }
  }
  
  result
}

// Deep merge function - recursively merges dictionaries
#let merge-dict(target, source) = {
  let result = target

  for (key, value) in source {
    if key in target {
      let target-value = target.at(key)
      if type(target-value) == dictionary and type(value) == dictionary {
        result.insert(key, merge-dict(target-value, value))
      } else if type(target-value) == array and type(value) == array {
        result.insert(key, merge-arrays(target-value, value))
      } else {
        result.insert(key, value)
      }
    } else {
      result.insert(key, value)
    }
  }

  result
}

// Main data loader function
// Usage: #let data = load-resume-data("en")
#let load-resume-data(lang) = {
  // Load common data (shared across all languages)
  let common-data = yaml("../data/common.yaml")

  // Resolve language code to file name
  let lang-code = lang-file-map.at(lang, default: lang)
  let lang-file = "../data/resume." + lang-code + ".yaml"

  // Load language-specific data
  let lang-data = yaml(lang-file)

  // Return merged data (language-specific overrides common)
  merge-dict(common-data, lang-data)
}

// Get supported languages
#let supported-languages = lang-file-map.keys()
