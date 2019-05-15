# frozen_string_literal: true

class Event < ApplicationRecord
  belongs_to :project
  belongs_to :user, optional: true

  enum status: %i[active resolved muted]

  validates :title, :status, presence: true

  acts_as_list scope: %i[status project_id]
  scope :by_status, ->(status) { where(status: status) if status.present? }

  before_create :assign_parent

  private

  def assign_parent
    self.parent_id = ::Events::ParentCreateService.call(event: self, project: project)
  end
end
