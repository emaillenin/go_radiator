require_relative 'xml_to_radiator_transformer'

class Retriever

  def get_data(profile = "no-profile")
    if configatron.test_mode
      radiator = get_xml_test(configatron.test_file_name)
    elsif configatron.demo_mode
      radiator = get_xml_test(configatron.demo_file_name)
    else
      radiator = get_cctray_response configatron.url, configatron.domain, configatron.user, configatron.password
    end
    pipeline_reducer(radiator, profile)
  end

  def get_pipeline_data name
    get_xml_test.pipelines.each do |pipeline|
       return pipeline if pipeline.name.downcase == name.downcase
    end
    Pipeline.new "Pipeline Not Found", "N/A", "N/A"
  end

  private
  def get_xml_test file_name
    file = IO.read(File.dirname(__FILE__) + '/' + file_name.to_s)
    xml_doc = Nokogiri::XML(file)

    XmlToRadiatorTransformer.new.transform xml_doc
  end

  def get_cctray_response(url, domain, user, password)
    http_client = HTTPClient.new
    http_client.set_auth(domain, user, password)
    xml_doc = Nokogiri::XML(http_client.get(url).body)

    XmlToRadiatorTransformer.new.transform xml_doc
  end

  def pipeline_reducer(radiator, pipelines)

    return radiator if pipelines == "no-profile"

    pipeline_include = pipelines.split(';')
    if pipeline_include.length > 0
      radiator.pipelines.delete_if {  |pipeline| !pipeline_include.include?(pipeline.name) }
    end

    radiator
  end

end