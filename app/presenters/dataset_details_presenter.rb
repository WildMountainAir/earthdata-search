class DatasetDetailsPresenter < DetailsPresenter
  def initialize(dataset, collection_id=nil)
    @dataset = dataset
    @dataset.id = collection_id
    @dataset.spatial = spatial(dataset.spatial)
    @dataset.science_keywords = science_keywords(dataset.science_keywords)
    @dataset.contacts = contacts(dataset.contacts)
    @dataset.temporal = temporal(dataset.temporal)
    @dataset.associated_difs = associated_difs(dataset.associated_difs)

    metadata_url = "https://api.echo.nasa.gov/catalog-rest/echo_catalog/datasets/#{@dataset.id}"
    @dataset.native_url = "#{metadata_url}"
    @dataset.atom_url = "#{metadata_url}.atom"
    @dataset.echo10_url = "#{metadata_url}.echo10"
    @dataset.iso19115_url = "#{metadata_url}.iso19115"
    @dataset.smap_iso_url = nil #"#{metadata_url}.smap_iso"
  end

  def associated_difs(dif_id)
    url = "http://gcmd.gsfc.nasa.gov/getdif.htm?#{dif_id}"
    {url: url, id: dif_id}
  end

  def contacts(hash)
    if hash
      contact_list = Array.wrap(hash.map do |contact_person|
        person = contact_person['ContactPersons']
        if person && person['ContactPerson']
          name = "#{person['ContactPerson']['FirstName']} #{person['ContactPerson']['LastName']}"
        else
          name = contact_person['OrganizationName'] || nil
        end
        if contact_person['OrganizationPhones'] && contact_person['OrganizationPhones']['Phone']
          phone = contact_person['OrganizationPhones']['Phone']
          phones = Array.wrap(phone).map{ |p| "#{p['Number']} (#{p['Type']})" }
        else
          phones = []
        end
        if contact_person['OrganizationEmails']
          email = contact_person['OrganizationEmails']['Email']
        else
          email = nil
        end

        {name: name, phones: phones, email: email}
      end)
    else
      contact_list = ['Not available']
    end

    contact_list
  end

  def science_keywords(keywords)
    if keywords
      keywords.map{ |k| "#{k['CategoryKeyword']} >> #{k['TopicKeyword']} >> #{k['TermKeyword']}" }.uniq
    else
      ['Not available']
    end
  end
end
