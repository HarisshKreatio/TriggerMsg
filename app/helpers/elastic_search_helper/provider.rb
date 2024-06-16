module ElasticSearchHelper

  class Provider

    def self.form_all_provider_elastic_query(params, entity_type)
      must = []
      must += ElasticSearchHelper::Provider.name(params[:inputName]) if params[:inputName].present?
      must << ElasticSearchHelper::Provider.identifier(params[:inputNpi]) if params[:inputNpi].present?

      must << ElasticSearchHelper::Provider.source_name(params[:inputSource]) if params[:inputSource].present?
      must << ElasticSearchHelper::Provider.updated_date(params[:inputUpdatedDate]) if params[:inputUpdatedDate].present?
      must << ElasticSearchHelper::Provider.stable_id(params[:inputStableId]) if params[:inputStableId].present?

      must << ElasticSearchHelper::Provider.loc_stable_id(params[:inputLocStableId]) if params[:inputLocStableId].present?
      must << ElasticSearchHelper::Provider.address_text(params[:inputAddrText]) if params[:inputAddrText].present?
      must << ElasticSearchHelper::Provider.address_city(params[:inputAddrCity]) if params[:inputAddrCity].present?
      must << ElasticSearchHelper::Provider.address_state(params[:inputAddrState]) if params[:inputAddrState].present?
      must << ElasticSearchHelper::Provider.address_zip(params[:inputAddrZip]) if params[:inputAddrZip].present?

      search_size = params[:inputSize].present? ? params[:inputSize].to_i : 10000

      if must.present?
        if entity_type == 'provider'
          query_for_provider(search_size, must)
        elsif entity_type == 'provider_single_doc'
          query_for_provider_single_doc(search_size, must)
        end
      else
        {
          "size": search_size,
          "query": {
            "match_all": {}
          }
        }
      end
    end

    def self.query_for_provider(search_size, must)
      {
        "size": search_size,
        "query": {
          "nested": {
            "path": "practitionerRole",
            "query": {
              "bool": {
                "must": must
              }
            }
          }
        }
      }
    end

    def self.query_for_provider_single_doc(search_size, must)
      must = JSON.parse(must.to_json.gsub('practitionerRole.', ''))
      {
        "size": search_size,
        "query": {
          "bool": {
            "must": must
          }
        }
      }
    end
    
    def self.name(name)
      [
        {
          "nested": {
            "path": "practitionerRole.practitioner",
            "query": {
              "nested": {
                "path": "practitionerRole.practitioner.name",
                "query": {
                  "bool": {
                    "must": [
                      {
                        "match": {
                          "practitionerRole.practitioner.name.text": {
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
          }
        }
      ]
    end

    def self.identifier(identifier)
      {
        "nested": {
          "path": "practitionerRole.practitioner.identifier",
          "query": {
            "bool": {
              "must": [
                {
                  "match": {
                    "practitionerRole.practitioner.identifier.value": {
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
          "practitionerRole.meta.source": {
            "query": "#{name}",
            "operator": "and"
          }
        }
      }
    end

    def self.updated_date(updated_date)
      {
        "match": {
          "practitionerRole.meta.updated": {
            "query": "#{updated_date}",
            "operator": "and"
          }
        }
      }
    end

    def self.stable_id(stable_id)
      {
        "nested": {
          "path": "practitionerRole.practitioner",
          "query": {
            "bool": {
              "must": [
                {
                  "match": {
                    "practitionerRole.practitioner.stableId": {
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
          "path": "practitionerRole.location",
          "query": {
            "bool": {
              "must": [
                {
                  "match": {
                    "practitionerRole.location.stableId": {
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
          "path": "practitionerRole.location",
          "query": {
            "nested": {
              "path": "practitionerRole.location.address",
              "query": {
                "match": {
                  "practitionerRole.location.address.text": {
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
          "path": "practitionerRole.location",
          "query": {
            "nested": {
              "path": "practitionerRole.location.address",
              "query": {
                "match": {
                  "practitionerRole.location.address.city": {
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
          "path": "practitionerRole.location",
          "query": {
            "nested": {
              "path": "practitionerRole.location.address",
              "query": {
                "match": {
                  "practitionerRole.location.address.state": {
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
          "path": "practitionerRole.location",
          "query": {
            "nested": {
              "path": "practitionerRole.location.address",
              "query": {
                "match": {
                  "practitionerRole.location.address.postalCode": {
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

end
