require 'axlsx'

class HomeController < ApplicationController
  def index
  end

  def new_trigger_message
  end

  def new_excel_gen
  end

  def file_process_trigger
    entity_name = params[:entity_type]
    entity_profile = get_profile(entity_name)
    batch_size = params[:batch_size].to_i
    flag = get_flag_json(params[:flag])
    file = params[:file]
    fetch_batch_id = params[:batch_id_gen].present?
    output_file_name = "trig_msg_#{Time.now.strftime('%H:%M:%S')}"
    file_content = generate_trigger_file(entity_name, entity_profile, batch_size, flag, file, fetch_batch_id)
    content_string = file_content.join("\n")
    send_data content_string, filename: "#{output_file_name}.txt", type: "text/plain"
  end

  def process_excel
    file = params[:file]
    output_file_name = "ingestion_report_#{Time.now.strftime('%H:%M:%S')}.xlsx"
    xlsx_package = generate_xlsx(file)
    send_data xlsx_package.to_stream.read, filename: output_file_name, type: "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"
  end

  private

  def get_flag_json(flag_type)
    case flag_type
    when 'NO_FLAG'
      nil
    when 'OVERWRITE'
      { 'overwriteRecords': true }.as_json
    when 'FORCE'
      { 'forceReMatchOnDupes': true }.as_json
    when 'OVERWRITE_FORCE'
      { 'overwriteRecords': true, 'forceReMatchOnDupes': true }.as_json
    else
      nil
    end
  end

  def get_profile(entity_type)
    case entity_type
    when 'provider'
      'http://hl7.org/fhir/us/core/StructureDefinition/us-core-practitionerrole'
    when 'facility'
      'http://hl7.org/fhir/us/core/STU5.0.1/StructureDefinition/us-core-OrganizationAffiliation'
    else
      nil
    end
  end

  def all_source_names
    %w[wa-kaiserwa wa-kaisernw wa-regence-bs wa-premera wa-amerigroup wa-molina wa-uhc wa-deltadental wa-dentegra wa-chpw wa-lifewise wa-bridgespan wa-cc-medicaid wa-cc-exchange wa-pacificsource or-regence-bcbs or-uhc wa-licensure us-nppes wa-cc-cascade]
  end

  def file_read_sort(file)
    lines = File.readlines(file).map(&:chomp)
    cleaned_lines = lines.compact.map(&:strip).reject(&:blank?)
    sort_arr = cleaned_lines.each_slice(4).to_a
    sort_arr.sort_by { |_, _, _, size| size.to_f }
  end

  def clean_up_fields(each_line_set, entity_name, fetch_batch_id)
    source_name = each_line_set[0].downcase
    source_name = all_source_names.include?(source_name) ? source_name : 'not_valid_source'
    path = each_line_set[1]
    path = (path.starts_with?('https') && path.ends_with?('ndjson')) ? path : 'url_issue'
    date = each_line_set[2]
    size = each_line_set[3]
    file_name = File.basename(path)
    batch_id = if fetch_batch_id.present? && file_name.present? && (file_name.include?('provider:') || file_name.include?('facility:'))
                 file_name.match(/(provider|facility):(.{1,36})/)[0] rescue "#{entity_name}:#{SecureRandom.uuid}"
               else
                 "#{entity_name}:#{SecureRandom.uuid}"
               end
    [source_name, size, file_name, path, date, batch_id]
  end

  def generate_trigger_file(entity_name, entity_profile, batch_size, flag, file, fetch_batch_id)
    sorted_lines = file_read_sort(file)
    write_arr = []
    sl_no = 1
    sorted_lines.each do |each_line_set|
      source_name, size, file_name, path, date, batch_id = clean_up_fields(each_line_set, entity_name, fetch_batch_id)
      write_arr << "#{sl_no}. #{source_name} [#{size}, #{date}]\n\n\n"
      trigger_msg_json = {
        "meta": {
          "SourceCode": source_name,
          "SourceFilePath": path,
          "profile": entity_profile,
          "batchId": batch_id
        },
        "processRules": {
          "batchSize": batch_size
        }
      }.as_json
      flag.present? ? trigger_msg_json['processRules'].merge!(flag) : nil
      write_arr << JSON.pretty_generate(trigger_msg_json, indent: '    ')
      write_arr << "\n\n"
      write_arr << '--------------------------------------------------------'
      sl_no += 1
    end
    write_arr
  end

  def generate_xlsx(file)
    xlsx = Axlsx::Package.new
    workbook = xlsx.workbook
    header_style = workbook.styles.add_style(bg_color: 'cccccc', b: true, border: Axlsx::STYLE_THIN_BORDER)
    worksheet = workbook.add_worksheet
    row_style = worksheet.styles.add_style(border: Axlsx::STYLE_THIN_BORDER)
    headers = ['SL.NO', 'Source Name', 'Size', 'File Name', 'Path', 'Date', 'Ingested Date', 'Ingestion Status', 'ndjson Verified']
    worksheet.add_row(headers, style: header_style)
    sorted_lines = file_read_sort(file)
    row_num = 1
    sl_no = 1
    sorted_lines.each do |each_line_set|
      source_name, size, file_name, path, date, batch_id = clean_up_fields(each_line_set, '', false)
      row_data = [sl_no, source_name, size, file_name, path, date, Date.today.strftime("%m/%d/%Y"), 'In Progress', 'In Progress']
      worksheet.add_row(row_data, style: row_style)
      row_num += 1
      sl_no += 1
    end
    xlsx
  end

end
