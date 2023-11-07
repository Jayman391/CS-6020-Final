data {
  int<lower=1> n;                        // Number of nodes
  int<lower=0> X[n, n];                  // Interaction matrix, where X[i, j] is the number of Interactions between i to j

  // Priors for post rates and comment rates standard deviations
  real<lower=0> post_rates_std_prior[2,2]; 
  real<lower=0> comment_rates_std_prior[2,2]; 
  real<lower=0> rho_prior[2];
  vector<lower=1>[n] degree;             // "Degree" of each node, turn interaction matrix to adj matrix where if there were any interactions 
                                         // they are connected in interaction graph, should make graph preferential
}
parameters {
  positive_ordered[2] post_rates;        // Ordered vector for post rates
  positive_ordered[2] comment_rates;     // Ordered vector for comment rates
  real<lower=0, upper=1> rho;            // Edge presence probability, the baseline probability of an edge between any two nodes
}

model {
  // Priors for post rates and comment rates
  post_rates[1] ~ beta(post_rates_std_prior[1,1], post_rates_std_prior[1,2]); 
  post_rates[2] ~ beta(post_rates_std_prior[2,2], post_rates_std_prior[2,1]); 
  comment_rates[1] ~ beta(comment_rates_std_prior[1,1], comment_rates_std_prior[1,2]); 
  comment_rates[2] ~ beta(comment_rates_std_prior[2,1], comment_rates_std_prior[2,2]); 
  rho ~­ beta(rho_prior[1], rho_prior[2]);

  // Loop over all node pairs to calculate the log likelihood
  for (i in 1:n) {
    for (j in i + 1:n) {
      // Calculate the log likelihood of the observed edges under a Poisson model
      real log_mu_ij_0 = poisson_lpmf(X[i, j] | post_rates[1] , comment_rates[2]);
      real log_mu_ij_1 = poisson_lpmf(X[i, j] | post_rates[2] , comment_rates[2]);

      // Adjust rho to include the preferential attachment effect, using the inv_logit function for transformation
      real adjusted_rho = inv_logit(rho *  degree[i] * degree[j]);

      // Calculate the log likelihood for the presence or absence of an edge
      real log_nu_ij_0 = bernoulli_lpmf(0 | adjusted_rho);
      real log_nu_ij_1 = bernoulli_lpmf(1 | adjusted_rho);

      // Combine the log likelihoods for the Poisson and Bernoulli parts
      real z_ij_0 = log_mu_ij_0 + log_nu_ij_0;
      real z_ij_1 = log_mu_ij_1 + log_nu_ij_1;

      // Increment the target log posterior with the log mixture likelihood
      if (z_ij_0 > z_ij_1) {
        target += z_ij_0 + log1p_exp(z_ij_1 - z_ij_0);
      } else {
        target += z_ij_1 + log1p_exp(z_ij_0 - z_ij_1);
      }
    }
  }
}

generated quantities {
  real Q[n ,n]; // Matrix to store the probabilities of edges between each pair of nodes
  for (i in 1:n) {
    Q[i, i] = 0; // Diagonal elements are 0, no self-loops
    for (j in i+1:n) {
      // Repeating the calculations from the model block to determine edge probabilities
      real log_mu_ij_0 = poisson_lpmf(X[i, j] | post_rates[1] , comment_rates[2]);
      real log_mu_ij_1 = poisson_lpmf(X[i, j] | post_rates[2] , comment_rates[2]);

      real adjusted_rho = inv_logit(rho *  degree[i] * degree[j]);

      real log_nu_ij_0 = bernoulli_lpmf(0 | adjusted_rho);
      real log_nu_ij_1 = bernoulli_lpmf(1 | adjusted_rho);

      real z_ij_0 = log_mu_ij_0 + log_nu_ij_0;
      real z_ij_1 = log_mu_ij_1 + log_nu_ij_1;
      
      // Calculate the edge probability matrix Q, using the softmax function
      Q[i, j] = 1 / (1  + exp(z_ij_0 - z_ij_1));
      Q[j, i] = Q[i, j]; // Symmetric matrix, as the graph is undirected
    }
  }
}
