class QueriesController < ApplicationController

  before_filter :load_user

  def index
    if params[:command]
      @command = @user.commands.find_by_keyword(params[:command])
      @queries = @command.queries.paginate(:order => "queries.created_at DESC", :page => params[:page]) if owner? || @command.public?
    else
      publicity = owner? ? "any" : "public"
      @queries = @user.queries.send(publicity).paginate({:order => "queries.created_at DESC", :page => params[:page], :include => [:command]})
    end
    
    respond_to do |format|
      format.html # show.rhtml
      format.xml  { render :xml => @queries.to_xml }
    end
  end

  def edit
    raise "You are not allowed to edit this query." unless owner?
    @query = current_user.queries.find(params[:id])
  end
  
  def update
    raise "You are not allowed to update this query." unless owner?
    @query = current_user.queries.find(params[:id])

    respond_to do |format|
      if @query.update_attributes(params[:query])
        flash[:notice] = "Query updated: <b>#{@query.query_string}</b>"
        format.html { redirect_to current_user.home_path }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @query.errors.to_xml }
      end
    end
  end

  def destroy
    raise "You are not allowed to delete this query." unless owner?

    @query = current_user.queries.find(params[:id])
    @query.destroy

    respond_to do |format|
      flash[:notice] = "Query deleted: <b>#{@query.query_string}</b>"
      format.html { redirect_to current_user.home_path }
      format.xml  { head :ok }
    end
  end


end
