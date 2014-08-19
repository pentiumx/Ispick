#require 'scrape'

module Scrape

  # スクレイピング処理を行うクラス群の親クラス
  class Client
    include Scrape
    attr_accessor :logger, :limit, :pid_debug, :sleep_debug
    ROOT_URL = ''

    # Initializes a new Client object
    #
    # @param limit [Integer]
    # @param logger [Logger]
    # @return [Scrape::Client]
    def initialize(logger=nil, limit=1)
      self.limit = limit
      # Generate an instance of a default logger
      if logger.nil?
        self.logger = Logger.new('log/scrape.log')
      else
        self.logger = logger
      end
      self.logger.formatter = ActiveSupport::Logger::SimpleFormatter.new
    end


    # 定時配信時、タグ検索APIを用いて抽出するサイト用の関数
    # Scrape images from websites which has api. The latter two params are used for testing.
    # @param module_type [String]
    # @param [Integer] min
    # @param logger [Logger] logger instance to output logs.
    # @param [Boolean] whether it's called for debug or not
    # @param [Boolean] whether it's called for debug or not
    def scrape_target_words(module_type, interval=60)
      # 予備時間が十分に取れない程短時間の場合は例外を発生させる
      if interval < 15
        raise Exception.new('the interval argument must be more than 10!')
        return
      end

      #child_module = Object::const_get(module_type)
      reserved_time = 10
      local_interval = (interval-reserved_time) / (TargetWord.count*1.0)

      @logger.info '--------------------------------------------------'
      @logger.info "Start extracting from #{self.class::ROOT_URL}"
      @logger.info "interval=#{interval} local_interval=#{local_interval}"

      # PIDファイルを用いて多重起動を防ぐ
      #Scrape.detect_multiple_running(module_type, false)
      detect_multiple_running(false)

      # １タグごとにタグ検索APIを用いて画像取得
      TargetWord.all.each do |target_word|
        begin
          # パラメータに基づいてAPIリクエストを行い結果を得る
          if (not target_word.word.nil?) and (not target_word.word.empty?)
            result = scrape_using_api(target_word)
            @logger.info "scraped: #{result[:scraped]}, duplicates: #{result[:duplicates]}, skipped: #{result[:skipped]}, avg_time: #{result[:avg_time]}"

            # [保留中]海外サイトの場合は英名でも検索する
            #if module_type == 'Scrape::Tumblr'
            #  # english=trueで呼ぶ
            #  result = child_module.scrape_using_api(target_word, limit, logger, true, false, true)
            #  logger.info "scraped: #{result[:scraped]}, duplicates: #{result[:duplicates]}, skipped: #{result[:skipped]}, avg_time: #{result[:avg_time]}"
            #end
          end
        rescue => e
          @logger.info e
          logger.error "Scraping from #{self.class::ROOT_URL} has failed!"
        end

        sleep_time = local_interval*60
        logger.info "Sleeping #{local_interval} minutes."
        sleep(sleep_time) unless @sleep_debug
      end
      @logger.info '--------------------------------------------------'
    end

    def scrape_using_api(target_word)
      { scraped: 0, duplicates: 0, avg_time: 0 }
    end


    # PIDファイルを用いて多重起動を防ぐ
    # @param [Boolean] PidFileを使用するかどうか
    # @param [Boolean] デバッグ出力を行うかどうか
    def detect_multiple_running(debug=false)
      unless @pid_debug
        if PidFile.running? # PidFileが存在する場合はプロセスを終了する
          @logger.info 'Another process is already runnnig. Exit.'
          exit
        end

        # PidFileが存在しない場合、新たにPidFileを作成し、
        # 新たにプロセスが生成されるのを防ぐ
        pid_hash = {
          #pidfile: "#{module_type}.pid",
          pidfile: "#{self.class.name}.pid",
          piddir: "#{Rails.root}/tmp/pids"
        }
        p = PidFile.new(pid_hash)

        # デフォルトでは/tmp以下にPidFileが作成される
        @logger.debug 'PidFile DEBUG:'
        @logger.debug p.pidfile
        @logger.debug p.piddir
        @logger.debug p.pid
        @logger.debug p.pidpath
      end
    end


    # Imageレコードを新たに生成してDBに保存する
    # @param [Hash] Imageレコードに与える属性のHash
    # @param [Array] 関連するタグ(String)の配列
    # @param [Boolean] validationを行うかどうか
    # @param [Boolean] 大きいサイズの画像かどうか
    # @param [Boolean] ログ出力を行うかどうか
    # @return [Integer] 保存されたImageレコードのID。失敗した場合はnil
    #def self.save_image(attributes, tags=[], validation=true, large=false, verbose=false, resque=true)
    def self.save_image(attributes, logger, tags=[], options={})
      #logger.debug "save_image options: #{options.inspect} #{options[:validation]}"
      # 予め（ダウンロードする前に）重複を確認
      if options[:validation] and Scrape.is_duplicate(attributes[:src_url])
        logger.info 'Skipping a duplicate image...' if options[:verbose]
        return
      end

      # Remove 4 bytes chars
      attributes[:caption] = Scrape.remove_4bytes(attributes[:caption])

      # 新規レコードを作成
      image = Image.new attributes
      tags.each { |tag| image.tags << tag }

      # 高頻度で失敗し得るのでsave!ではなくsaveを使用する
      # ダウンロード・特徴抽出処理をgenerate_jobs内で非同期的に行う
      if image.save(validate: options[:validation])
        Scrape::Client.generate_jobs(image.id, attributes[:src_url], options[:large]) unless options[:resque]
      else
        logger.info 'Image model saving failed. (maybe due to duplication)'
        return
      end
      image.id
    end


    # 既にsaveしたImageレコードに対してダウンロード・画像解析処理を
    # Resqueのjobとして行う（非同期的に）
    def self.generate_jobs(image_id, src_url, large=false, user_id=nil, target_type=nil, target_id=nil, logger=nil)
      if user_id and target_type and target_id
        if large
          Resque.enqueue(DownloadImageLarge, image_id, src_url,
            user_id, target_type, target_id)
        else
          #logger.info "with #{user_id}: #{image_id}" if logger
          Resque.enqueue(DownloadImage, image_id, src_url,
            user_id, target_type, target_id)
        end
      else
        if large
          Resque.enqueue(DownloadImageLarge, image_id, src_url)
        else
          #logger.info "without #{user_id}: #{image_id}" if logger
          Resque.enqueue(DownloadImage, image_id, src_url)
        end
      end
    end
  end
end
