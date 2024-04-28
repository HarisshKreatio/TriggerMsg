module ElasticSearchHelper

  class Facility
    def self.name(name)
      {
        "nested": {
          "path": "organizationAffiliation.facility",
          "query": {
            "bool": {
              "must": [
                {
                  "match": {
                    "organizationAffiliation.facility.name": {
                      "query": "#{name}",
                      "operator": "and"
                    }
                  }
                }
              ]
            }
          }
        }
      }
    end

    def self.identifier(identifier)
      {
        "nested": {
          "path": "organizationAffiliation.facility.identifier",
          "query": {
            "bool": {
              "must": [
                {
                  "match": {
                    "organizationAffiliation.facility.identifier.value": {
                      "query": "#{identifier}",
                      "operator": "and"
                    }
                  }
                }
              ]
            }
          }
        }
      }
    end

    def self.source_name(name)
      {
        "match": {
          "organizationAffiliation.meta.source": {
            "query": "#{name}",
            "operator": "and"
          }
        }
      }
    end

    def self.updated_date(updated_date)
      {
        "match": {
          "organizationAffiliation.meta.updated": {
            "query": "#{updated_date}",
            "operator": "and"
          }
        }
      }
    end

    def self.stable_id(stable_id)
      {
        "nested": {
          "path": "organizationAffiliation.facility",
          "query": {
            "bool": {
              "must": [
                {
                  "match": {
                    "organizationAffiliation.facility.stableId": {
                      "query": "#{stable_id}",
                      "operator": "and"
                    }
                  }
                }
              ]
            }
          }
        }
      }
    end

    def self.loc_stable_id(loc_stable_id)
      {
        "nested": {
          "path": "organizationAffiliation.location",
          "query": {
            "bool": {
              "must": [
                {
                  "match": {
                    "organizationAffiliation.location.stableId": {
                      "query": "#{loc_stable_id}",
                      "operator": "and"
                    }
                  }
                }
              ]
            }
          }
        }
      }
    end

    def self.address_text(text)
      {
        "nested": {
          "path": "organizationAffiliation.location",
          "query": {
            "nested": {
              "path": "organizationAffiliation.location.address",
              "query": {
                "match": {
                  "organizationAffiliation.location.address.text": {
                    "query": "#{text}",
                    "operator": "and"
                  }
                }
              }
            }
          }
        }
      }
    end

    def self.address_city(city)
      {
        "nested": {
          "path": "organizationAffiliation.location",
          "query": {
            "nested": {
              "path": "organizationAffiliation.location.address",
              "query": {
                "match": {
                  "organizationAffiliation.location.address.city": {
                    "query": "#{city}",
                    "operator": "and"
                  }
                }
              }
            }
          }
        }
      }
    end

    def self.address_state(state)
      {
        "nested": {
          "path": "organizationAffiliation.location",
          "query": {
            "nested": {
              "path": "organizationAffiliation.location.address",
              "query": {
                "match": {
                  "organizationAffiliation.location.address.state": {
                    "query": "#{state}",
                    "operator": "and"
                  }
                }
              }
            }
          }
        }
      }
    end

    def self.address_zip(zip)
      {
        "nested": {
          "path": "organizationAffiliation.location",
          "query": {
            "nested": {
              "path": "organizationAffiliation.location.address",
              "query": {
                "match": {
                  "organizationAffiliation.location.address.postalCode": {
                    "query": "#{zip}",
                    "operator": "and"
                  }
                }
              }
            }
          }
        }
      }
    end

  end

  class Provider

  end

end
