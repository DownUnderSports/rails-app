Sport.insert_all([
  { abbr_gendered: "BBB", name_gendered: "Boys Basketball",  abbr: "BB", name: "Basketball"      },
  { abbr_gendered: "GBB", name_gendered: "Girls Basketball", abbr: "BB", name: "Basketball"      },
  { abbr_gendered: "CH",  name_gendered: "Cheer",            abbr: "CH", name: "Cheer"           },
  { abbr_gendered: "XC",  name_gendered: "Cross Country",    abbr: "XC", name: "Cross Country"   },
  { abbr_gendered: "FB",  name_gendered: "Football",         abbr: "FB", name: "Football"        },
  { abbr_gendered: "GF",  name_gendered: "Golf",             abbr: "GF", name: "Golf"            },
  { abbr_gendered: "TF",  name_gendered: "Track and Field",  abbr: "TF", name: "Track and Field" },
  { abbr_gendered: "VB",  name_gendered: "Volleyball",       abbr: "VB", name: "Volleyball"      },
  { abbr_gendered: "STF", name_gendered: "Staff",            abbr: "ST", name: "Staff"           }
], unique_by: :abbr_gendered)

Rails.logger.info { "Seeded Sports: #{Sport.count}" }
