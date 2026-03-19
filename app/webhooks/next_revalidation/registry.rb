module NextRevalidation
  class Registry
    DEFINITIONS = {
      "ArchiveTag" => {
        tags: ["tags"],
      },
      "Location" => {
        tags: ["locations"],
      },
      "CommGroup" => {
        tags: ["comm_groups"],
      },
      "Person" => {
        tags: ["people"],
      },
      "Collection" => {
        tags: ["collections"],
      },
    }.freeze

    def self.for(record)
      definition = DEFINITIONS[record.class.name]
      return { tags: [], paths: [] } unless definition

      result = definition.respond_to?(:call) ? definition.call(record) : definition
      {
        tags: Array(result[:tags]).uniq,
        paths: Array(result[:paths]).uniq
      }
    end
  end
end