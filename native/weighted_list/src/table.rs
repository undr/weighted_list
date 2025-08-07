use serde::{Deserialize, Serialize};

#[derive(Serialize, Deserialize, Debug, PartialEq, Clone, Default)]
pub struct Table {
    values: Vec<u32>,
    // Alias to another index
    aliases: Vec<usize>,
    // Probability for whether to output the index attached to `aliases`.
    probs: Vec<f32>,
}

impl Table {
    pub fn build(values: Vec<u32>, weights: Vec<u32>) -> Option<Table> {
        Some(Builder::new(values, weights).build())
    }

    // Creates a new instance of [`Table`].
    pub fn new(values: Vec<u32>, aliases: Vec<usize>, probs: Vec<f32>) -> Table {
        Table {
            values: values,
            aliases: aliases,
            probs: probs,
        }
    }

    pub fn size(&self) -> usize {
        self.values.len()
    }

    pub fn get_values(&self) -> Vec<u32> {
        self.values.clone().to_vec()
    }

    pub fn get_probs(&self) -> Vec<f32> {
        self.probs.clone().to_vec()
    }

    pub fn get_aliases(&self) -> Vec<usize> {
        self.aliases.clone().to_vec()
    }

    pub fn get(&self, idx: u32, rnd: f32) -> Option<u32> {
        match self.get_idx(idx, rnd) {
            Some(widx) => self.values.get(widx as usize).copied(),
            None => None,
        }
    }

    pub fn get_idx(&self, idx: u32, rnd: f32) -> Option<u32> {
        match self.probs.get(idx as usize) {
            Some(&prob) => {
                if rnd < prob {
                    self.aliases
                        .get(idx as usize)
                        .and_then::<u32, fn(&usize) -> Option<u32>>(|v| Some(*v as u32))
                } else {
                    Some(idx)
                }
            },
            None => None,
        }
    }
}

struct Builder {
    values: Vec<u32>,
    weights: Vec<u32>,
}

impl Builder {
    fn new(values: Vec<u32>, weights: Vec<u32>) -> Builder {
        let table_len = weights.len() as u32;

        // Process that the mean of weights does not become a float value
        let ws = weights
            .iter()
            .map(|w| w * table_len)
            .collect::<Vec<u32>>();

        Builder { weights: ws, values: values }
    }

    pub fn build(&self) -> Table {
        let table_len = self.weights.len();
        let values = self.values.clone().to_vec();

        if self.sum() == 0 {
            // Returns WalkerTable that performs unweighted random sampling.
            return Table::new(values, vec![0; table_len], vec![0.0; table_len]);
        }

        let (aliases, probs) = self.calc_table();

        Table::new(values, aliases, probs)
    }

    /// Calculates the sum of `weights`.
    fn sum(&self) -> u32 {
        self.weights.iter().fold(0, |acc, cur| acc + cur)
    }

    /// Calculates the mean of `weights`.
    fn mean(&self) -> u32 {
        self.sum() / self.weights.len() as u32
    }

    /// Returns the tables of aliases and probabilities.
    fn calc_table(&self) -> (Vec<usize>, Vec<f32>) {
        let table_len = self.weights.len();
        let (mut below_vec, mut above_vec) = self.separate_weight();
        let mean = self.mean();

        let mut aliases = vec![0; table_len];
        let mut probs = vec![0.0; table_len];
        loop {
            match below_vec.pop() {
                Some(below) => {
                    if let Some(above) = above_vec.pop() {
                        let diff = mean - below.1;
                        aliases[below.0] = above.0 as usize;
                        probs[below.0] = diff as f32 / mean as f32;
                        if above.1 - diff <= mean {
                            below_vec.push((above.0, above.1 - diff));
                        } else {
                            above_vec.push((above.0, above.1 - diff));
                        }
                    } else {
                        aliases[below.0] = below.0 as usize;
                        probs[below.0] = below.1 as f32 / mean as f32;
                    }
                }
                None => break,
            }
        }

        (aliases, probs)
    }

    /// Divide the values of `weights` based on the mean of them.
    ///
    /// The tail value is a weight and head is its index.
    fn separate_weight(&self) -> (Vec<(usize, u32)>, Vec<(usize, u32)>) {
        let mut below_vec = Vec::with_capacity(self.weights.len());
        let mut above_vec = Vec::with_capacity(self.weights.len());
        for (i, w) in self.weights.iter().enumerate() {
            if *w <= self.mean() {
                below_vec.push((i, *w));
            } else {
                above_vec.push((i, *w));
            }
        }
        (below_vec, above_vec)
    }
}


#[cfg(test)]
mod table_test {
    use crate::table::Table;

    #[test]
    fn make_table_from_u32() {
        let values = vec![12, 17, 19, 12, 14, 18, 11, 13, 16, 15];
        let weights = vec![2, 7, 9, 2, 4, 8, 1, 3, 6, 5];
        let w_table = Table::build(values, weights).unwrap();

        let expected = Table::new(
            vec![12, 17, 19, 12, 14, 18, 11, 13, 16, 15],
            vec![2, 1, 1, 2, 2, 2, 5, 9, 5, 8],
            vec![
                0.574468085106383,
                1.0,
                0.48936170212766,
                0.574468085106383,
                0.148936170212766,
                0.106382978723404,
                0.787234042553192,
                0.361702127659574,
                0.0212765957446809,
                0.297872340425532,
            ],
        );

        assert_eq!(w_table, expected)
    }

    #[test]
    fn make_table_when_sum_is_zero() {
        let values = vec![0; 5];
        let weights = vec![0; 5];
        let w_table = Table::build(values, weights).unwrap();

        let expected = Table::new(vec![0; 5], vec![0; 5], vec![0.0; 5]);

        assert_eq!(w_table, expected)
    }
}
