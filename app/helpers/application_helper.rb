module ApplicationHelper
  # B→KBに換算する
  # @param [Integer] byte[B]
  # @return [Integer] kilobyte[KB]
  def bytes_to_kilobytes(byte)
    return 0 unless byte      # nilの場合0を返す
    (byte / 1024.0).round(3)
  end

  # B→MBに換算する
  # @param [Integer] byte[B]
  # @return [Integer] megabyte[MB]
  def bytes_to_megabytes(byte)
    return 0 unless byte
    (byte / (1024.0*1024.0)).round(3)
  end

  # @param [Integer] byte[B]
  # @return [Integer] kilobyte[KB]
  def bytes_to_kilobytes_mac(byte)
    return 0 unless byte
    (byte / 1000.0).round(3)
  end

  # @param [Integer] byte[B]
  # @return [Integer] megabyte[MB]
  def bytes_to_megabytes_mac(byte)
    return 0 unless byte
    (byte / (1000.0*1000.0)).round(3)
  end


  # Image/DeliveredImageのrelationの画像サイズを合計して返す
  # @param [ActiveRecord::Relation] Image/DeliveredImageのrelationオブジェクト
  # @return [Integer] 容量の合計[byte]
  def get_total_size(images)
    return 0 if images.nil?

    total_size = 0
    images.each do |i|
      next if i.nil?
      total_size += i.data.size if i.data and i.data.size
    end
    total_size
  end

  # @param datetime [DateTime]
  # @return [DateTime]
  def utc_to_jst(datetime)
    datetime ? datetime.in_time_zone('Asia/Tokyo') : 'unknown'
  end

  # @param datetime [DateTime]
  # @return [String]
  def get_time_string(datetime)
    datetime ? datetime.strftime("%d %B %Y, %H:%M") : 'unknown'
  end

  # @param datetime [DateTime]
  # @return [String]
  def get_jst_string(datetime)
    datetime ? get_time_string(utc_to_jst(datetime)) : 'unknown'
  end

  # @param datetime [DateTime]
  # @return [String]
  def get_time_string_ja(datetime)
    datetime ? datetime.strftime("%Y年%m月%d日%H時%M分") : 'unknown'
  end

  # @param datetime [DateTime]
  # @return [String]
  def get_jst_string_ja(datetime)
    datetime ? get_time_string_ja(utc_to_jst(datetime)) : 'unknown'
  end
end
