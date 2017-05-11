require 'rest-client'
require 'json'

  DETECT_API = "https://api-cn.faceplusplus.com/facepp/v3/detect";
  API_KEY = "PPg_gb56FSwbuELKZXQmvYKzbeY0mgHA";
  API_SECRET = "BBiQGVefMR0SdrFXcsGtVbW5P9i9DEND";
  result_file = File.new("result_file_2.csv", 'a+');
  
  retry_count = 0;
  total_count = 0;
  array = ["test_image/2/video6030_9.jpg"]
  array.each do |img_file| 
    puts "#{total_count} #{img_file}"
    begin
      res = RestClient.post(
        DETECT_API, 
        { :image_file => File.new(img_file, 'rb'),
          :api_key => API_KEY,
          :api_secret => API_SECRET,
          :return_attributes => "gender,age,smiling",
        })

      if(res.code == 200)
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
            result_file.write("#{img_file}, #{i+1}, #{attributes["gender"]["value"]}, #{attributes["age"]["value"]}, #{is_smile}\n");
          end
        end
      else
        puts "#{img_file} #{res.code}";
      end
      total_count = total_count + 1;
      sleep(0.05)
    rescue StandardError => e
      puts e;
      retry_count = retry_count+1
      if(retry_count < 3)
        sleep(1)
        redo
      else
        retry_count = 0;
      end
    end
  end
  result_file.close;