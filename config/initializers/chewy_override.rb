module ChewyOverride

  Chewy::Index::Actions::ClassMethods.prepend(ChewyOverride)

  # def exists?
  #   print_error('exists?')
  # end

  def create(*args, **kwargs)
    print_error('create')
  end

  def create!(suffix = nil, **options)
    print_error('create!')
  end

  def delete(suffix = nil)
    print_error('delete')
  end

  def delete!(suffix = nil)
    print_error('delete!')
  end

  def purge(suffix = nil)
    print_error('purge')
  end

  def purge!(suffix = nil)
    print_error('purge!')
  end

  def reset(suffix = nil, apply_journal: true, journal: false, **import_options)
    print_error('reset')
  end

  def reset!(suffix = nil, apply_journal: true, journal: false, **import_options)
    print_error('reset!')
  end

  def journal
    print_error('journal')
  end

  def clear_cache(args = {index: index_name})
    print_error('clear_cache')
  end

  def reindex(source: index_name, dest: index_name)
    print_error('reindex')
  end

  def update_mapping(name = index_name, body = root.mappings_hash)
    print_error('update_mapping')
  end

  def sync(parallel: nil)
    print_error('sync')
  end

  def print_error(method_name)
    "#{method_name} method is blocked"
  end

end
