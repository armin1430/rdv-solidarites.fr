module RdvsHelper
  def rdv_title(rdv)
    "Le #{l(rdv.starts_at, format: :human)} (durée : #{rdv.duration_in_min} minutes)"
  end

  def agents_to_sentence(rdv)
    rdv.agents.map(&:full_name_and_service).sort.to_sentence
  end

  def users_to_links(rdv)
    safe_join(rdv.users.order_by_last_name.map do |user|
      link_to user.full_name, user_show_path(user), target: '_blank'
    end, ", ")
  end

  def users_to_sentence(rdv)
    users = []
    rdv.users.each do |user|
      users << user if user == current_user || current_user.children.include?(user)
    end
    users.map(&:full_name).sort.to_sentence
  end

  def rdv_status_tag(rdv)
    content_tag(:span, Rdv.human_enum_name(:status, rdv.status), class: 'badge badge-info')
  end

  def no_rdv_for_users
    sentence = "Vous n'avez pas de RDV "
    sentence += params[:past].present? ? "passé." : "à venir."
    sentence
  end

  def human_location(rdv)
    rdv.location.blank? ? 'Non précisé' : rdv.location
  end

  def rdv_tag(rdv)
    if rdv.cancelled_at
      content_tag(:span, 'Annulé', class: 'badge badge-warning')
    elsif rdv.starts_at.future?
      content_tag(:span, 'À venir', class: 'badge badge-info')
    end
  end
end
