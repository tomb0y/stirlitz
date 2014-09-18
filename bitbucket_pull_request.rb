# Schema Info
#
# Table name: bit_bucket_pull_requests
#
#  id                   :integer
#  title                :string
#  description          :text
#  self_link            :string
#  merge_link           :string
#  approve_link         :string
#  decline_link         :string
#  state                :string
#  pr_id                :integer
#  source_commit_link   :string
#  source_commit_hash   :string
#  repository_name      :string
#  repository_full_name :string
#  repository_link      :string
#  created_at           :datetime
#  updated_at           :datetime
#

require 'curb'

class BitbucketPullRequest < Sequel::Model

  plugin :validation_helpers
  plugin :timestamps, update_on_create: true
  plugin :update_or_create

  def validate
    super
    validates_presence [:title, :self_link, :merge_link, :approve_link,
                        :decline_link, :state, :pr_id, :source_commit_link,
                        :source_commit_hash, :repository_name,
                        :repository_full_name, :repository_link]
    validates_unique :pr_id
  end

  def approve!
    ar = Curl::Easy.http_post(approve_link){ |c| set_bitbucket_basic_auth(c) }
    ar.response_code == 200
  end

  def unapprove!
    ur = Curl::Easy.http_delete(approve_link){ |c| set_bitbucket_basic_auth(c) }
    ur.response_code == 200
  end

  private

  def set_bitbucket_basic_auth(c)
    c.http_auth_types = :basic
    c.username = ENV['BITBUCKET_USERNAME']
    c.password = ENV['BITBUCKET_PASSWORD']
  end

end