class Api::WorkloadsController < ApplicationController
  def complete
    workload = Workload.where(facebook_id: current_user.facebook_id).order('created_at desc').first
    #if workload.created_at + Workload.pomotime <= Time.now
    if true
      workload.number = workload.next_number
      workload.is_done = true
      workload.save!
      hash = JSON.parse(workload.to_json)
      hash['created_at'] = workload['created_at'].to_i * 1000
      workload = hash
    end
    render json: workload
  end

  def chattings
    res = Workload.chattings.map{|w|
      hash = JSON.parse(w.to_json)
      hash['created_at'] = w.created_at.to_i * 1000 # JSはマイクロ秒
      hash
    }.reverse
    render json: res
  end

  def playings
    res = Workload.playings.map{|w|
      hash = JSON.parse(w.to_json)
      hash['created_at'] = w.created_at.to_i * 1000 # JSはマイクロ秒
      hash
    }.reverse!
    render json: res
  end

  def dones
    limit = params[:limit] || 48
    render json: Workload.dones(limit).map{|w|
      hash = JSON.parse(w.to_json)
      hash['created_at'] = w.created_at.to_i * 1000 # JSはマイクロ秒
      hash
    }.reverse!
  end

  def yours
    limit = params[:limit] || 48
    render json: Workload.yours(current_user, limit).map{|w|
      hash = JSON.parse(w.to_json)
      hash['created_at'] = w.created_at.to_i * 1000 # JSはマイクロ秒
      hash
    }.reverse!
  end

  def your_bests
    limit = params[:limit] || 48
    render json: Workload.your_bests(current_user, limit).map{|w|
      hash = JSON.parse(w.to_json)
      hash['created_at'] = w.created_at.to_i * 1000 # JSはマイクロ秒
      hash
    }.reverse!
  end

  def create
    workload = Workload.create!(
      facebook_id: current_user.facebook_id,
      music_key: params['music_key'].presence,
      title: params['title'].presence,
      artwork_url: params['artwork_url'].presence
    )
    workload = JSON.parse(workload.to_json)
    workload['created_at'] = workload['created_at'].to_i * 1000
    render json: workload
  end
end
