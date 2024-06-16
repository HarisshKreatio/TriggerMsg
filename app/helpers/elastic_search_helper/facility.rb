module ElasticSearchHelper

  class Facility

    def self.form_all_facility_elastic_query(params, entity_type)
      must = []
      must << ElasticSearchHelper::Facility.name(params[:inputName]) if params[:inputName].present?
      must << ElasticSearchHelper::Facility.identifier(params[:inputNpi]) if params[:inputNpi].present?

      must << ElasticSearchHelper::Facility.source_name(params[:inputSource]) if params[:inputSource].present?
      must << ElasticSearchHelper::Facility.updated_date(params[:inputUpdatedDate]) if params[:inputUpdatedDate].present?
      must << ElasticSearchHelper::Facility.stable_id(params[:inputStableId]) if params[:inputStableId].present?

      must << ElasticSearchHelper::Facility.loc_stable_id(params[:inputLocStableId]) if params[:inputLocStableId].present?
      must << ElasticSearchHelper::Facility.address_text(params[:inputAddrText]) if params[:inputAddrText].present?
      must << ElasticSearchHelper::Facility.address_city(params[:inputAddrCity]) if params[:inputAddrCity].present?
      must << ElasticSearchHelper::Facility.address_state(params[:inputAddrState]) if params[:inputAddrState].present?
      must << ElasticSearchHelper::Facility.address_zip(params[:inputAddrZip]) if params[:inputAddrZip].present?

      search_size = params[:inputSize].present? ? params[:inputSize].to_i : 10000

      if must.present?
        if entity_type == 'facility'
          query_for_facility(search_size, must)
        elsif entity_type == 'facility_single_doc'
          query_for_facility_single_doc(search_size, must)
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

    def self.query_for_facility(search_size, must)
      {
        "size": search_size,
        "query": {
          "nested": {
            "path": "organizationAffiliation",
            "query": {
              "bool": {
                "must": must
              }
            }
          }
        }
      }
    end

    def self.query_for_facility_single_doc(search_size, must)
      must = JSON.parse(must.to_json.gsub('organizationAffiliation.', ''))
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

end
