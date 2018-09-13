require 'uri'
require 'cgi'

Dir[File.dirname(__FILE__) + 'features/support/*.rb'].each { |f| require f }

module WithinHelpers
  def with_scope(locator)
    locator ? within(locator) { yield } : yield
  end
end

World(WithinHelpers)

Dado /^que (?:|eu )estou em (.+)$/ do |page_name|
  visit path_to(page_name)
end

Quando /^(?:|eu )vou para (.+)$/ do |page_name|
  visit path_to(page_name)
end

Quando /^(?:|eu )pressiono "([^\"]*)"(?: em "([^\"]*)")?$/ do |button, selector|
  with_scope(selector) do
    click_button(button)
  end
end

Quando /^(?:|eu )clico "([^\"]*)"(?: em "([^\"]*)")?$/ do |link, selector|
  with_scope(selector) do
    click_link(link)
  end
end

Quando /^(?:|eu )preencho o campo "([^\"]*)" com "([^\"]*)"(?: em "([^\"]*)")?$/ do |field, value, selector|
  with_scope(selector) do
    fill_in(field, :with => value)
  end
end

Quando /^(?:|eu )preencho com "([^\"]*)" para "([^\"]*)"(?: em "([^\"]*)")?$/ do |value, field, selector|
  with_scope(selector) do
    fill_in(field, :with => value)
  end
end

# Use this to fill in an entire form with data from a table. Example:
#
#   When I fill in the following:
#     | Account Number | 5002       |
#     | Expiry date    | 2009-11-01 |
#     | Note           | Nice guy   |
#     | Wants Email?   |            |
#
# TODO: Add support for checkbox, select og option
# based on naming conventions.
#
Quando /^(?:|eu )preencho com(?: em "([^\"]*)")?:$/ do |selector, fields|
  with_scope(selector) do
    fields.rows_hash.each do |name, value|
      Quando %{eu preencho o campo "#{name}" com "#{value}"}
    end
  end
end

Quando /^(?:|eu )seleciono "([^\"]*)" para "([^\"]*)"(?: em "([^\"]*)")?$/ do |value, field, selector|
  with_scope(selector) do
    select(value, :from => field)
  end
end

Quando /^(?:|eu )marco "([^\"]*)"(?: em "([^\"]*)")?$/ do |field, selector|
  with_scope(selector) do
    check(field)
  end
end

Quando /^(?:|eu )desmarco "([^\"]*)"(?: em "([^\"]*)")?$/ do |field, selector|
  with_scope(selector) do
    uncheck(field)
  end
end

Quando /^(?:|eu )escolho "([^\"]*)"(?: em "([^\"]*)")?$/ do |field, selector|
  with_scope(selector) do
    choose(field)
  end
end

Quando /^(?:|eu )anexo o arquivo "([^\"]*)" para "([^\"]*)"(?: em "([^\"]*)")?$/ do |path, field, selector|
  with_scope(selector) do
    attach_file(field, path)
  end
end

Entao /^(?:|eu )deveria ver JSON:$/ do |expected_json|
  require 'json'
  expected = JSON.pretty_generate(JSON.parse(expected_json))
  actual   = JSON.pretty_generate(JSON.parse(response.body))
  expected.should == actual
end

Entao /^(?:|eu )deveria ver "([^\"]*)"(?: em "([^\"]*)")?$/ do |text, selector|
  with_scope(selector) do
    if page.respond_to? :should
      page.should have_content(text)
    else
      assert page.has_content?(text)
    end
  end
end

Entao /^(?:|eu )deveria ver \/([^\/]*)\/(?: em "([^\"]*)")?$/ do |regexp, selector|
  regexp = Regexp.new(regexp)
  with_scope(selector) do
    if page.respond_to? :should
      page.should have_xpath('//*', :text => regexp)
    else
      assert page.has_xpath?('//*', :text => regexp)
    end
  end
end

Entao /^(?:|eu )não deveria ver "([^\"]*)"(?: em "([^\"]*)")?$/ do |text, selector|
  with_scope(selector) do
    if page.respond_to? :should
      #page.should have_no_content(text)
      expect(page).to have_no_content(text)
    else
      assert page.has_no_content?(text)
    end
  end
end

Entao /^(?:|eu )não deveria ver \/([^\/]*)\/(?: em "([^\"]*)")?$/ do |regexp, selector|
  regexp = Regexp.new(regexp)
  with_scope(selector) do
    if page.respond_to? :should
      page.should have_no_xpath('//*', :text => regexp)
    else
      assert page.has_no_xpath?('//*', :text => regexp)
    end
  end
end

Entao /^o campo "([^\"]*)"(?: em "([^\"]*)")? deveria conter "([^\"]*)"$/ do |field, selector, value|
  with_scope(selector) do
    field = find_field(field)
    field_value = (field.tag_name == 'textarea') ? field.text : field.value
    if field_value.respond_to? :should
      field_value.should =~ /#{value}/
    else
      assert_match(/#{value}/, field_value)
    end
  end
end

Entao /^o campo "([^\"]*)"(?: em "([^\"]*)")? não deveria conter "([^\"]*)"$/ do |field, selector, value|
  with_scope(selector) do
    field = find_field(field)
    field_value = (field.tag_name == 'textarea') ? field.text : field.value
    if field_value.respond_to? :should_not
      field_value.should_not =~ /#{value}/
    else
      assert_no_match(/#{value}/, field_value)
    end
  end
end

Entao /^o checkbox "([^\"]*)"(?: em "([^\"]*)")? deveria esta marcado$/ do |label, selector|
  with_scope(selector) do
    field_checked = find_field(label)['checked']
    if field_checked.respond_to? :should
      field_checked.should == 'checked'
    else
      assert_equal 'checked', field_checked
    end
  end
end

Entao /^o checkbox "([^\"]*)"(?: em "([^\"]*)")? deveria não está marcado$/ do |label, selector|
  with_scope(selector) do
    field_checked = find_field(label)['checked']
    if field_checked.respond_to? :should_not
      field_checked.should_not == 'checked'
    else
      assert_not_equal 'checked', field_checked
    end
  end
end
 
Entao /^(?:|eu )deveria estar (?:|em )(.+)$/ do |page_name|
  current_path = URI.parse(current_url).path
  if current_path.respond_to? :should
    current_path.should == path_to(page_name)
  else
    assert_equal path_to(page_name), current_path
  end
end

Entao /^(?:|eu )deveria ter a seguinte query string:$/ do |expected_pairs|
  query = URI.parse(current_url).query
  actual_params = query ? CGI.parse(query) : {}
  expected_params = {}
  expected_pairs.rows_hash.each_pair{|k,v| expected_params[k] = v.split(',')} 
  
  if actual_params.respond_to? :should
    actual_params.should == expected_params
  else
    assert_equal expected_params, actual_params
  end
end


Entao /^mostre-me a página$/ do
  save_and_open_page
end

### QA

Quando(/^eu preencho o campo "(.*?)" com o valor "(.*?)"$/) do |pid, pval|
  find(:id, pid).set(pval)
end

Quando(/^eu clico em sair$/) do
  find('.ls-dropdown.ls-user-account > a').click
  click_link('sair')
end

Quando /^eu espero por (\d+) segundos?$/ do |n|
  sleep(n.to_i)
end

Entao /^(?:|eu )verei "([^\"]*)"(?: em "([^\"]*)")?$/ do |text, selector|
  if selector
    expect(page).to have_css selector, :text => text
  end
end
