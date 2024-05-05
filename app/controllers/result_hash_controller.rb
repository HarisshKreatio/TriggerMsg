class ResultHashController < ApplicationController

  def get_input
  end

  def index
    begin
      result_hash = JSON.parse(params[:inputResultHash])
      if not result_hash.is_a?(Hash)
        flash[:alert] = "Please provide a JSON object"
        redirect_to result_hash_get_input_path
      elsif not result_hash['tenant'].present? && result_hash['ENV'].present? && result_hash['index_name'].present?
        flash[:alert] = "Missing tenant/ENV/Index_name"
        redirect_to result_hash_get_input_path
      else
        @tenant = result_hash['tenant'].capitalize
        @environment = result_hash['ENV'].upcase
        @index_name = result_hash['index_name']

        @entity_type = get_entity_type(@index_name)
        if @entity_type == 'tenant_index'
          @result_hash = tenant_index(result_hash)
        else
          @result_hash = single_doc_index(result_hash)
        end
      end
    rescue
      flash[:alert] = "Error in Parsing JSON. Check the result_hash"
      redirect_to result_hash_get_input_path
    end
  end

  private

  def get_entity_type(index_name)
    if index_name.downcase.include?('facility') || index_name.downcase.include?('provider')
      'tenant_index'
    else
      'single_doc_index'
    end
  end

  def tenant_index(result_hash)
    result_hash.each do |key, value|
      next if %w[entity tenant ENV index_name].include?(key)

      if key == 'location' && value['location_must_not_exist'] != 0
        value['outputColor'] = 'red'
      end

      if value['total_records_in_db'].present?
        if value.count > 6
          value['extra_batch_id_count'] = value.count - 6
        end

        if value['difference'] != 0 || value['difference'].to_s == 'false'
          value['outputColor'] = 'red'
          value['note'] = value['difference'] < 0 ? 'Old records are still present in index' : 'Few records have to be send for Index'
        else
          value['outputColor'] = 'green'
        end
      end
    end
    %w[entity tenant ENV index_name location].each do |key|
      result_hash.delete(key)
    end
    result_hash
  end

  def single_doc_index(result_hash)
    result_hash.each do |key, value|
      next if %w[entity tenant ENV index_name].include?(key)

      if key == 'location' && value['location_must_not_exist'] != 0
        value['outputColor'] = 'red'
      end

      if value['total_records_in_db'].present?
        if value.count > 5
          value['extra_batch_id_count'] = value.count - 5
        end

        if value['difference'] != 0 || value['difference'].to_s == 'false'
          value['outputColor'] = 'red'
          value['note'] = value['difference'] < 0 ? 'Old records are still present in index' : 'Few records have to be send for Index'
        else
          value['outputColor'] = 'green'
        end
      end
    end
    %w[entity tenant ENV index_name location].each do |key|
      result_hash.delete(key)
    end
    result_hash
  end

end
