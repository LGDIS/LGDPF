# -*- coding:utf-8 -*-
class ActiveResourceController < ApplicationController
  
  # ActiveResource
  # LGDPF => LGDPM People取得処理
  # ==== Args
  # ==== Return
  # ==== Raise
  def people
    @people = Person.find(:all, :conditions => ["link_flag = ?", false])
    
    respond_to do |format|
      format.json { render :json => @people.to_json }
    end
  end
  
  # ActiveResource
  # LGDPF => LGDPM Note取得処理
  # ==== Args
  # _person_record_id_ :: 避難者ID
  # ==== Return
  # ==== Raise
  def note
    @note = Note.find(:first,
      :conditions => ["person_record_id = ? AND link_flag = ?",
      params[:person_record_id], false], :order => "created_at DESC")
      
    respond_to do |format|
      format.json { render :json => (@note.present? ? @note.to_json : Note.new.to_json) }
    end
  end
  
  # ActiveResource
  # LGDPF => LGDPM People更新処理
  # ==== Args
  # _id_ :: 避難者ID
  # ==== Return
  # ==== Raise
  def people_update
    @person = Person.find(params[:id])
    @person.update_attributes(:link_flag => true)
    
    respond_to do |format|
      format.json { render :json => @person.to_json }
    end
  end
  
  # ActiveResource
  # LGDPF => LGDPM Note更新処理
  # ==== Args
  # _id_ :: 安否情報ID
  # ==== Return
  # ==== Raise
  def note_update
    @note   = Note.find(params[:id])
    @note.update_attributes(:link_flag => true)
    
    respond_to do |format|
      format.json { render :json => @note.to_json }
    end
  end
end
