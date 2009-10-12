class Contacts
  class Gmail < Base
    
    CONTACTS_SCOPE = 'http://www.google.com/m8/feeds/'
    CONTACTS_FEED = CONTACTS_SCOPE + 'contacts/default/full/'
    
    def contacts
      return @contacts if @contacts
    end
    
    def real_connect
      @client = GData::Client::Contacts.new
      @client.clientlogin(@login, @password)
      
      feed = @client.get(CONTACTS_FEED).to_xml
      
      @contacts = feed.elements.to_a('entry').collect do |entry|
        title, email = entry.elements['title'].text, nil
        entry.elements.each('gd:email') do |e|
          email = e.attribute('address').value if e.attribute('primary')
        end
        [title, email] unless email.nil?
      end
      @contacts.compact!
    rescue GData::Client::AuthorizationError => e
      raise Contacts::AuthenticationError
    end
    
    private
    
    TYPES[:gmail] = Gmail
  end
end