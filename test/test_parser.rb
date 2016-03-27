require 'minitest/autorun'
require 'minitest/unit'
require 'parser'
require 'fixmessage'

include QuickFixRuby::Fix

class TestParser < Minitest::Test

  GOOD_MESSAGE  = "8=FIX.4.1\x019=61\x0135=A\x0134=1\x0149=EXEC\x0152=20121105-23:24:06\x0156=BANZAI\x0198=0\x01108=30\x0110=003\x01"

  def test_parse_with_bad_message
    parser = Parser.new
    msg =  parser.parse 'garbage'
    assert_instance_of(ParseFailure, msg)
  end

  def test_parse_with_good_message
    parser = Parser.new

    total = 0
    msg_cut = GOOD_MESSAGE.gsub(/10\=[^\x01]+\x01/, '')
    msg_cut.each_char do |i| total += i.ord end

    #print "MSG:" + msg_cut +"\n"
    print "debug:#{(total % 256)}"

    msg =  parser.parse GOOD_MESSAGE
    assert_instance_of(FixMessage, msg)
    assert_equal "A", msg.get_as_string(35)
    assert_equal 2012, msg.get_as_datetime(52).to_time.year
  end


end