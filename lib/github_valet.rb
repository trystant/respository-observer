module GithubValet
  require 'dotenv/load'
  require 'github_valet/version'
  require 'octokit'
  require 'pry-byebug'

  attr_accessor :client
  
  def self.readme_md_exists_for?(repository) 
    Octokit.readme(repository, access_token: ENV['OCTOKIT_TEST_GITHUB_TOKEN']).is_a?(Sawyer::Resource)
  rescue StandardError => error
    p "Error fetching repo: #{error}"
    false
  end
  
  def self.readme_md_exists_for_user_repo?(repository) 
    readme = Octokit.contents(repository, path: 'README.md', access_token: ENV['OCTOKIT_TEST_GITHUB_TOKEN'])
  rescue Octokit::NotFound => error
    false
  rescue StandardError => error
    p "Error fetching repo: #{error}"
    false
  end
  
  def self.find_repos_without_readme
    @client = Octokit::Client.new(
      netrc: true,
      per_page: 100,
      access_token: ENV['OCTOKIT_TEST_GITHUB_TOKEN']
    ) 
    results = ""
    @client.repositories('trystant').map { |repo| 
      "#{repo[:owner][:login]}/#{repo[:name]}" 
    }.each do |repo_string|
      unless self.readme_md_exists_for?(repo_string) 
       p "#{repo_string} has no README.md\n"
       results += "#{repo_string} has no README.md"
      end
    end
    results
  end
  
  def self.find_user_repos_without_readme
    @client = Octokit::Client.new(
      access_token: ENV['OCTOKIT_TEST_GITHUB_TOKEN']
    ) 
    results = ""
    repositories = @client.repositories('trystant', access_token: ENV['OCTOKIT_TEST_GITHUB_TOKEN'] )
    repositories.map { |repo| 
      "#{repo[:owner][:login]}/#{repo[:name]}" 
    }.each do |repo_string|
      unless self.readme_md_exists_for_user_repo?(repo_string) 
       p "#{repo_string} has no README.md"
       results += "#{repo_string} has no README.md"
      end
    end
    results
  end
end