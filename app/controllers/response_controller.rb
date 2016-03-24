class ResponseController < ApplicationController
  def responseOAuth
    uri = URI.parse("https://api.weibo.com/oauth2/access_token")
    res = Net::HTTP.post_form(uri, :client_id => APP_KEY, :client_secret => APP_SECRET,
                              :grant_type => :authorization_code, :code => params[:code],
                              :redirect_uri => "http://nyunyunyunyu.com/response&response_type=code")


    return_dict = JSON.load(res.body)
    user = SinaUser.find_by_uid(return_dict["uid"])
    if not user
      user = SinaUser.create access_token: return_dict["access_token"],
                             uid: return_dict["uid"],
                             expires_in: return_dict["expires_in"]
    else
      user.access_token = return_dict["access_token"]
      user.uid = return_dict["uid"]
      user.expires_in = return_dict["expires_in"]
      user.save
    end

    uri = URI.parse("https://api.weibo.com/2/users/show.json")
    query_params = {:access_token => return_dict["access_token"], :uid => return_dict["uid"]}
    uri.query = URI.encode_www_form(query_params)
    res = Net::HTTP.get_response(uri)
    info_dict = JSON.load(res.body)
    user.username = info_dict["screen_name"]
    user.save
    flash[:notice] = "You have successfully add your information."
    redirect_to root_path
  end
end
