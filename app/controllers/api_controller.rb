require "JSON"
class ApiController < ApplicationController
  def users
    now = DateTime::now
    users_list = []
    SinaUser.all.each do |u|
      if now < u.updated_at + u.expires_in.to_i
        users_list.append({:username => u.username, :uid => u.uid})
      end
    end
    response.stream.write JSON.dump({:users => users_list})
    response.stream.close
  end

  def posts
    user = SinaUser.find_by_uid params[:uid]
    if not user
      response.stream.write(JSON.dump({:error => 'there is no such user.'}))
      response.stream.close
    else
      uri = URI.parse("https://api.weibo.com/2/statuses/user_timeline.json")
      query_params = {:access_token => user.access_token, :count => 100, }
      uri.query = URI.encode_www_form(query_params)
      res = Net::HTTP.get_response(uri)
      status_dict = JSON.load(res.body)
      response_dict = {:statuses => status_dict["statuses"]}
      response.stream.write JSON.dump(response_dict)
      response.stream.close
    end
  end

  def emotion
    user = SinaUser.find_by_uid params[:uid]
    if not user
      response.stream.write(JSON.dump({:error => 'there is no such user.'}))
      response.stream.close
    else
      uri = URI.parse("https://api.weibo.com/2/statuses/user_timeline.json")
      query_params = {:access_token => user.access_token, :count => 100, }
      uri.query = URI.encode_www_form(query_params)
      res = Net::HTTP.get_response(uri)
      status_dict = JSON.load(res.body)
      query_list = []
      for status in status_dict["statuses"]
        emocion_list = status["text"].scan(/\[.*?\]/)
        emocion_str = ""
        for every in emocion_list
          emocion_str += emocion_str
        end
        query_list.append emocion_str
      end
      uri = URI.parse("http://api.bosonnlp.com/sentiment/analysis?weibo")
      https = Net::HTTP.new(uri.host, uri.port)
      req = Net::HTTP::Post.new(uri.path, initheader = {'Content-Type' => 'application/json',
                                                        'Accept' => 'application/json',
                                                        'X-Token' => 'lPo9lxOD.5493.rI2b6PltcHnp'})

      req.body = JSON.dump(query_list)
      res = https.request(req)
      emotion_list = JSON.load(res.body)
      emotion_res = [0, 0]
      if emotion_list and emotion_list.length > 0
        for i in emotion_list
          emotion_res[0] += i[0]
          emotion_res[1] += i[1]
        end
        emotion_res[0] /= emotion_list.length
        emotion_res[1] /= emotion_list.length
      end
      response.stream.write JSON.dump(emotion_res)
      response.stream.close
    end
  end
end
