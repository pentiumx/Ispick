require 'pp'
require 'rubygems'
#require 'AnimeFace'
require 'RMagick'

class TargetImagesService
  # URL先の画像の顔特徴量をデフォルト設定で抽出する
  def get_face_feature(image_url)
    image = Magick::ImageList.new(image_url)
    AnimeFace::detect(image)
  end

  def prefer(target_image)
    start_time = Time.now
    url = target_image.data.path.split('?')[0]
    image = Magick::ImageList.new(url)
    result = AnimeFace::detect(image)
    #result1 = AnimeFace::detect(image, { :step => 2.0, :min_window_size => 32, :scale_factor => 1.1 })
    end_time = Time.now
    time = (end_time - start_time).to_s

    { time: time, result: result }
  end


  def get_preferred_images(target_image)
    preferred = []
    target_colors = {}
    time_db=0
    time_calc=0
    t0=0
    t1=0
    t2=0
    images_count=[]

    # TargetImageの特徴量を取得
    # nilチェック
    if target_image.feature.nil? or target_image.feature.face.nil? or
      target_image.feature.face == '[]'
      return 'Feature of the target_image is invalid!'
    end
    face_features = JSON.parse(target_image.feature.face)


    face_features.each do |face_feature|
      target_colors = Utility::get_colors(face_feature, true)

      t0=Time.now
      # 抽出されていないか、抽出出来ていないImageは飛ばす
      images = Image.joins(:feature).where.not(features: { face: '[]' }).includes(:feature)

      # 最後に配信された日時より後に取得された画像のみ見る（それ以外は一度調べているはず）
      # nilだった場合は初めて配信対象となるtarget_imageなので全てのImageを見る
      if target_image.last_delivered_at
        images = images.where('images.created_at > ?', target_image.last_delivered_at)
      end
      t1=Time.now
      images_count.push(images.count)

      # Image.feature != nil and Image.feature != '[]'であるImageに対して：
      images.each do |image|
        image_faces = JSON.parse(image.feature.face)
        image_faces.each do |image_face|
          image_colors = Utility::get_colors(image_face, true)
          distance = Utility::get_hsv_distance(target_colors, image_colors)

          if Utility::is_preferred(distance, [30, 100, 100, 100])
            evaluation_value = Utility::evaluate_face_colors(distance, [5, 1, 1, 1])
            preferred.push({image: image, hsv: distance, value: evaluation_value})
          end
        end
      end

    end

    # Remove duplicates
    preferred.uniq! { |value| value[:image] }

    # sort
    preferred = preferred.sort_by do |value|
      value[:value]# 評価値でソート
    end

    # DEBUG: 時間計測
    t2=Time.now
    time_db=t1-t0
    time_calc=t2-t1

    {images: preferred, target_colors: target_colors,
      debug: { count: images_count, db: time_db, calc: time_calc }}
  end

end
