# frozen_string_literal: true

require "json"
require "test_helper"

class TestFunctionalFilters < Minitest::Spec
  make_my_diffs_pretty!

  data = JSON.parse <<~DATA
    {
      "closest": {
        "product": {
          "options_with_values": [
            {
              "name": "Size",
              "position": 1,
              "selected_value": {},
              "values": [
                {
                  "available": true,
                  "id": 123456,
                  "name": "Big",
                  "selected": true,
                  "swatch": null
                },
                {
                  "available": true,
                  "id": 654321,
                  "name": "Small"
                }
              ]
            },
            {
              "name": "Color",
              "position": 2,
              "selected_value": {},
              "values": [
                {
                  "available": true,
                  "id": 1234567,
                  "name": "Red",
                  "selected": true,
                  "swatch": {
                    "color": {},
                    "image": {}
                  }
                },
                {
                  "available": false,
                  "id": 7654321,
                  "name": "Green",
                  "swatch": {
                    "color": {},
                    "image": {}
                  }
                }
              ]
            },
            {
              "name": "Accent Color",
              "position": 3,
              "selected_value": {},
              "values": [
                {
                  "available": true,
                  "id": 876543,
                  "name": "Blue",
                  "selected": false,
                  "swatch": {
                    "color": {},
                    "image": {}
                  }
                },
                {
                  "available": true,
                  "id": 345678,
                  "name": "Yellow",
                  "swatch": {
                    "color": {},
                    "image": {}
                  }
                }
              ]
            }
          ]
        }
      }
    }
  DATA

  # TODO:
end
