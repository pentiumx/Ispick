class DetectIllust
  extend Resque::Plugins::Logger
  @queue = :detect_illust
  QUALITY_SIZE = 1

  # イラスト判定ツールを実行し結果を得る
  def self.get_result(tool_path, image)
    %x(#{tool_path} #{image.data.path} #{QUALITY_SIZE})
  end

  # イラストかどうか判定する
  def self.perform(image_id)
    begin
      # ツール実行
      image = Image.find(image_id)
      tool_path = CONFIG['illust_detection_path']

      # 結果をtrue/falseにparse
      result = self.get_result(tool_path, image).split(' ')
      illust = result.first.to_i
      quality = result.second.to_f
      is_illust = (illust == 1 ? true : false)

      # 対象attributeをupdate
      image.update_attributes({ is_illust: is_illust, quality: quality })
    rescue => e
      logger.info e
      logger.error('Illust detection failed!')
    end

    logger.info "Tool result: #{illust},#{quality} with Image.id=#{image_id}"
  end
end