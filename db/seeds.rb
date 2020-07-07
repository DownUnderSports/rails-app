# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

Sport.insert_all([
  { abbr_gendered: "BBB", full_gendered: "Boys Basketball",  abbr: "BB", full: "Basketball"      },
  { abbr_gendered: "GBB", full_gendered: "Girls Basketball", abbr: "BB", full: "Basketball"      },
  { abbr_gendered: "CH",  full_gendered: "Cheer",            abbr: "CH", full: "Cheer"           },
  { abbr_gendered: "XC",  full_gendered: "Cross Country",    abbr: "XC", full: "Cross Country"   },
  { abbr_gendered: "FB",  full_gendered: "Football",         abbr: "FB", full: "Football"        },
  { abbr_gendered: "GF",  full_gendered: "Golf",             abbr: "GF", full: "Golf"            },
  { abbr_gendered: "TF",  full_gendered: "Track and Field",  abbr: "TF", full: "Track and Field" },
  { abbr_gendered: "VB",  full_gendered: "Volleyball",       abbr: "VB", full: "Volleyball"      },
  { abbr_gendered: "STF", full_gendered: "Staff",            abbr: "ST", full: "Staff"           }
])
