require 'rest-client'
require 'json'

  DETECT_API = "https://api-cn.faceplusplus.com/facepp/v3/detect";
  API_KEY = "PPg_gb56FSwbuELKZXQmvYKzbeY0mgHA";
  API_SECRET = "BBiQGVefMR0SdrFXcsGtVbW5P9i9DEND";

  result_file = File.new("result_file_3.csv", 'w');
  error_file = File.new("result_error_3.csv", 'w');
  result_file.write("File Name, Index, Gender, Age, Smiling\n")
  
  retry_count = 0;
  total_count = 0;
  #puts "Set API_KET and API_SECRET"
  Dir.glob('test_image/3/*.jpg') do |img_file|
    puts "#{total_count} : #{img_file}"
    #puts "Read file : #{img_file}"
    begin
      #puts "\t Call Detect API with image file"
      res = RestClient.post(
        DETECT_API, 
        { :image_file => File.new(img_file, 'rb'),
          :api_key => API_KEY,
          :api_secret => API_SECRET,
          :return_attributes => "gender,age,smiling",
        })

      # { "image_id": "8dqfEZF/mQsKxWXv4wD6wg==", 
      #   "request_id": "1494328870,c56faeb7-1c8f-4d8e-a0c3-f3107a820a89", 
      #   "time_used": 237, 
      #   "faces": [{"attributes": {
      #     "gender": {"value": "Female"}, 
      #     "age": {"value": 33}, 
      #     "smile": {"threshold": 30.1, "value": 89.151}}, 
      #     "face_rectangle": {"width": 161, "top": 120, "left": 53, "height": 161}, 
      #     "face_token": "369a13806fc081950d7fdd758919a028"}]
      # }
      if(res.code == 200)
        #puts "\t Get response"
        retry_count = 0
        rb = JSON.parse(res.body)
        if(rb["faces"].count == 0)
          result_file.write("#{img_file}, 0, , , \n");
        else
          for i in 0...rb["faces"].count
            attributes = rb["faces"][i]["attributes"]
            is_smile = false
            if(attributes["smile"]["value"] > attributes["smile"]["threshold"])
              is_smile = true
            end
            #puts "\t\t face(#{i}) attributes #{attributes}"
            result_file.write("#{img_file}, #{i+1}, #{attributes["gender"]["value"]}, #{attributes["age"]["value"]}, #{is_smile}\n");
          end
        end
      else
        error_file.write("#{img_file}\n")
        puts "ERROR #{img_file} #{res.code}";
      end
      total_count = total_count + 1;
    rescue StandardError => e
      puts e;
      retry_count = retry_count+1
      if(retry_count < 5)
        sleep(1)
        redo
      else
        error_file.write("#{img_file}\n")
        retry_count = 0;
      end
    end
  end
  result_file.close;
  error_file.close;