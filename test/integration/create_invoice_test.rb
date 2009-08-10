require File.dirname(__FILE__) + '/../test_helper'

class CreateInvoiceTest < Test::Unit::TestCase
  include TestHelper
  
  def setup
    @gateway = XeroGateway::Gateway.new(
      :customer_key => CUSTOMER_KEY,
      :api_key => API_KEY    
    )
    
    if STUB_XERO_CALLS
      @gateway.xero_url = "DUMMY_URL"
      
      @gateway.stubs(:http_put).with {|url, body, params| url =~ /invoice$/ }.returns(get_file_as_string("invoice.xml"))          
      @gateway.stubs(:http_post).with {|url, body, params| url =~ /invoice$/ }.returns(get_file_as_string("invoice.xml"))          
    end
  end
  
  def test_create_invoice
    example_invoice = dummy_invoice.dup
    
    result = @gateway.create_invoice(example_invoice)
    assert_valid_invoice_save_response(result, example_invoice)
  end
  
  def test_create_from_invoice
    example_invoice = dummy_invoice.dup
    
    invoice = @gateway.build_invoice(example_invoice)
    result = invoice.create
    assert_valid_invoice_save_response(result, example_invoice)
  end
  
  private
  
    def assert_valid_invoice_save_response(result, example_invoice)
      assert_kind_of XeroGateway::Response, result
      assert result.success?
      assert !result.request_xml.nil?
      assert !result.response_xml.nil?
      assert !result.invoice.invoice_id.nil?
      assert result.invoice.invoice_number == example_invoice.invoice_number
      assert example_invoice.invoice_id =~ GUID_REGEX
    end
    
end