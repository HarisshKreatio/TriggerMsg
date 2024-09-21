class ResultHashController < ApplicationController

  def get_input
    unless session[:uniq_result_hash_id].present?
      clear_all_tmp_result_hash
    end
  end

  def process_input
    begin
      result_hash = JSON.parse(params[:inputResultHash])

      result_hash_checked = {}
      file_path = session[:uniq_result_hash_path]
      parsed_result_hashes = JSON.parse(File.read(file_path))
      if result_hash.is_a?(Hash)
        result_hash['entity_type'] = get_entity_type(result_hash['index_name'])
        if result_hash['entity_type'] == 'tenant_index'
          result_hash_checked = tenant_index(result_hash)
        else
          result_hash_checked = single_doc_index(result_hash)
        end
        parsed_result_hashes << result_hash_checked
      elsif result_hash.is_a?(Array)
        result_hash.each do |e_hash|
          unless e_hash['tenant'].present? && e_hash['ENV'].present? && e_hash['index_name'].present?
            flash[:alert] = "Missing tenant/ENV/Index_name"
            redirect_to result_hash_get_input_path
          end
          e_hash['entity_type'] = get_entity_type(e_hash['index_name'])
          if e_hash['entity_type'] == 'tenant_index'
            result_hash_checked = tenant_index(e_hash)
          else
            result_hash_checked = single_doc_index(e_hash)
          end
          parsed_result_hashes << result_hash_checked
        end
      else
        flash[:alert] = "Please provide a JSON object"
        redirect_to result_hash_get_input_path
      end
      File.open(file_path, 'w') { |file| file.write(parsed_result_hashes.to_json) }
      redirect_to result_hash_index_path
    rescue
      flash[:alert] = "Error in Parsing JSON. Check the result_hash"
      redirect_to result_hash_get_input_path
    end
  end

  def index
    file_path = session[:uniq_result_hash_path]
    @result_hashes = JSON.parse(File.read(file_path))
    unless @result_hashes.present?
      flash[:alert] = "No existing result hashes to Show"
      redirect_to result_hash_get_input_path
    end
  end

  def clear_result_hash
    clear_all_tmp_result_hash
    flash[:notice] = "Existing result hashes cleared"
    redirect_to result_hash_get_input_path
  end

  private

  def clear_all_tmp_result_hash
    public_directory = Rails.root.join('tmp')
    Dir.glob(File.join(public_directory, '*')).each do |file_path|
      if File.basename(file_path).ends_with?("_result_hashess.json")
        FileUtils.rm_rf(file_path)
      end
    end
    uniq_id = SecureRandom.uuid
    session[:uniq_result_hash_id] = uniq_id
    file_path = Rails.root.join('tmp', "#{session[:uniq_result_hash_id]}_result_hashess.json")
    session[:uniq_result_hash_path] = file_path
    File.open(file_path, 'w') { |file| file.write([]) }
  end

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
        if value.count > 7
          value['extra_batch_id_count'] = value.count - 7
        end

        if value['difference'] != 0 || value['difference'].to_s == 'false'
          value['outputColor'] = 'red'
          value['note'] = value['difference'] < 0 ? 'Old records are still present in index' : 'Few records have to be send for Index'
        else
          value['outputColor'] = 'green'
        end
      end
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
    result_hash
  end

end
