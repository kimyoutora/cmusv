class WelcomeController < ApplicationController
#  layout 'cmu_sv_simple'
   layout 'cmu_sv'

  def index
    @rss_feeds = RssFeed.all


    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @courses }
    end
  end

  def new_features
    
  end

  def configuration
    
  end

end
