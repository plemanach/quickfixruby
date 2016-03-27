require 'buffer'
require 'minitest/autorun'
require 'minitest/unit'

class TestBuffer < Minitest::Test

  NORMAL_LENGTH   = "8=FIX.4.2\x01" + "9=12\x01" + "35=A\x01" + "108=30\x01" + "10=31\x01"
  BAD_LENGTH      = "8=FIX.4.2\x01" + "9=A\x01"  + "35=A\x01" + "108=30\x01"  + "10=31\x01"
  NEGATIVE_LENGTH = "8=FIX.4.2\x01" + "9=-1\x01" + "35=A\x01" + "108=30\x01"  + "10=31\x01"
  INCOMPLETE_1    = "8=FIX.4.2";
  INCOMPLETE_2    = "8=FIX.4.2\x01" + "9=12";

  def test_extract_length_with_good_message

    buffer =  QuickFixRuby::Fix::Buffer.new

    buffer.add_to_stream(NORMAL_LENGTH)

    res = buffer.extract_length

    assert_equal 12, res[1]
    assert_equal 15, res[2]
  end


  def test_extract_length_with_bad_length

    buffer =  QuickFixRuby::Fix::Buffer.new

    buffer.add_to_stream(BAD_LENGTH)

    res = buffer.extract_length

    assert_equal false, res[0]
    assert_equal 0, res[1]
    assert_equal 0, res[2]
  end

  def test_extract_length_with_negative_length

    buffer =  QuickFixRuby::Fix::Buffer.new

    buffer.add_to_stream(NEGATIVE_LENGTH)

    res = buffer.extract_length

    assert_equal false, res[0]
    assert_equal 0, res[1]
    assert_equal 0, res[2]
  end

  def test_extract_length_with_negative_length

    buffer =  QuickFixRuby::Fix::Buffer.new

    buffer.add_to_stream(INCOMPLETE_2)

    res = buffer.extract_length

    assert_equal false, res[0]
    assert_equal 0, res[1]
    assert_equal 0, res[2]
  end


  def test_read_complete_fix_messages

    fixMsg1 = "8=FIX.4.2\x01" + "9=12\x01" + "35=A\x01" + "108=30\x01" + "10=31\x01";
    fixMsg2 = "8=FIX.4.2\x01" + "9=17\x01" + "35=4\x01" + "36=88\x01"  + "123=Y\x01"  + "10=34\x01";
    fixMsg3 = "8=FIX.4.2\x01" + "9=19\x01" + "35=A\x01" + "108=30\x01" + "9710=8\x01" + "10=31\x01";

    buffer = QuickFixRuby::Fix::Buffer.new
    buffer.add_to_stream(fixMsg1 + fixMsg2 + fixMsg3)

    fix1 = buffer.read_message
    assert_equal fixMsg1, fix1
            
    fix2 = buffer.read_message
    assert_equal fixMsg2, fix2

    fix3 = buffer.read_message
    assert_equal fixMsg3, fix3
  end

  def test_read_partial_fix_message
    partFixMsg1 = "8=FIX.4.2\x01" + "9=17\x01" + "35=4\x01" + "36=";
    partFixMsg2 = "88\x01" + "123=Y\x01" + "10=34\x01";

    buffer = QuickFixRuby::Fix::Buffer.new
    buffer.add_to_stream(partFixMsg1)

    readPartFixMsg = buffer.read_message
    assert_equal nil, readPartFixMsg

    buffer.add_to_stream(partFixMsg2)
    readPartFixMsg = buffer.read_message
    assert_equal partFixMsg1 + partFixMsg2, readPartFixMsg 
  end

  def test_read_fix_message_with_bad_length
    fixMsg = "8=TEST\x01" + "9=TEST\x01" + "35=TEST\x01" + "49=SS1\x01" + "56=RORE\x01" + "34=3\x01" + "52=20050222-16:45:53\x01" + "10=TEST\x01";

    buffer = QuickFixRuby::Fix::Buffer.new
    buffer.add_to_stream(fixMsg)
    readFixMsg = buffer.read_message

    assert_equal nil, readFixMsg

    #buffer get cleared
    readFixMsg = buffer.add_to_stream(NORMAL_LENGTH)
    assert_equal NORMAL_LENGTH, readFixMsg
  end

  def test_read_fix_message_with_non_ascii
    fixMsg1 = "8=FIX.4.4\x01" + "9=19\x01" + "35=B\x01" + "148=Ole!\x01" + "33=0\x01" + "10=0\x01"
    fixMsg2 = "8=FIX.4.4\x01" + "9=19\x01" + "35=B\x01" + "148=Ol@!\x01" + "33=0\x01" + "10=0\x01" 

    buffer = QuickFixRuby::Fix::Buffer.new
    buffer.add_to_stream(fixMsg1 + fixMsg2)
    readFixMsg1 = buffer.read_message()
    assert_equal fixMsg1, readFixMsg1


    readFixMsg2 = buffer.read_message()
    assert_equal fixMsg2, readFixMsg2
  end

  def test_read_fix_message_with_missing_values
    fixMsg1 = "8=FIX.4.4\x01" + "9=19\x01" + "35=B\x01" + "148=\x01" + "33=0\x01" + "10=0\x01"
    buffer = QuickFixRuby::Fix::Buffer.new
    buffer.add_to_stream(fixMsg1)
    
    readFixMsg1 = buffer.read_message()
    assert_equal fixMsg1, readFixMsg1
  end

end