# Copyright (c) 2016 Uber Technologies, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

namespace cpp jaegertracing.sampling_manager.thrift
namespace java io.jaegertracing.thrift.sampling_manager
namespace php Jaeger.Thrift.Agent
namespace netcore Jaeger.Thrift.Agent
namespace lua jaeger.thrift.agent

enum SamplingStrategyType { PROBABILISTIC, RATE_LIMITING, TAIL_BASED }

// Config holds the configuration for tail-based sampling.
struct TailBasedSamplingStrategy {
	// DecisionWait is the desired wait time from the arrival of the first span of
	// trace until the decision about sampling it or not is evaluated.
	1: required i16 decisionWait
	// NumTraces is the number of traces kept on memory. Typically most of the data
	// of a trace is released after a sampling decision is taken.
	2: required i16 numTraces
	// ExpectedNewTracesPerSec sets the expected number of new traces sending to the tail sampling processor
	// per second. This helps with allocating data structures with closer to actual usage size.
	3: optional i16 expectedNewTracesPerSec
	// PolicyCfgs sets the tail-based sampling policy which makes a sampling decision
	// for a given trace when requested.
	4: required list<TailBasedSamplingPolicy> policies
}

struct TailBasedSamplingPolicy {
    1: required string name
    2: required TailBasedSamplingPolicyType type
    3: optional NumericAttributeStrategy numericAttributeStrategy
    4: optional StringAttributeStrategy stringAttributeStrategy
}

struct NumericAttributeStrategy {
  // Tag that the filter is going to be matching against.
  1: required string key
  // MinValue is the minimum value of the attribute to be considered a match.
  2: required i16 min
  // MaxValue is the maximum value of the attribute to be considered a match.
  3: required i16 max
}

// StringAttributeCfg holds the configurable settings to create a string attribute filter
// sampling policy evaluator.
struct StringAttributeStrategy {
  // Tag that the filter is going to be matching against.
  1: required string key
  // Values is the set of attribute values that if any is equal to the actual attribute value to be considered a match.
  2: required list<string> values
}

enum TailBasedSamplingPolicyType { ALWAYS_SAMPLE, NUMERIC_ATTRIBUTE, STRING_ATTRIBUTE }

// ProbabilisticSamplingStrategy randomly samples a fixed percentage of all traces.
struct ProbabilisticSamplingStrategy {
    1: required double samplingRate // percentage expressed as rate (0..1]
}

// RateLimitingStrategy samples traces with a rate that does not exceed specified number of traces per second.
// The recommended implementation approach is leaky bucket.
struct RateLimitingSamplingStrategy {
    1: required i16 maxTracesPerSecond
}

// OperationSamplingStrategy defines a sampling strategy that randomly samples a fixed percentage of operation traces.
struct OperationSamplingStrategy {
    1: required string operation
    2: required ProbabilisticSamplingStrategy probabilisticSampling
}

// PerOperationSamplingStrategies defines a sampling strategy per each operation name in the service
// with a guaranteed lower bound per second. Once the lower bound is met, operations are randomly sampled
// at a fixed percentage.
struct PerOperationSamplingStrategies {
    1: required double defaultSamplingProbability
    2: required double defaultLowerBoundTracesPerSecond
    3: required list<OperationSamplingStrategy> perOperationStrategies
    4: optional double defaultUpperBoundTracesPerSecond
}

struct SamplingStrategyResponse {
    1: required SamplingStrategyType strategyType
    2: optional ProbabilisticSamplingStrategy probabilisticSampling
    3: optional RateLimitingSamplingStrategy rateLimitingSampling
    4: optional PerOperationSamplingStrategies operationSampling
    5: optional TailBasedSamplingStrategy TailBasedSampling
}

service SamplingManager {
    SamplingStrategyResponse getSamplingStrategy(1: string serviceName)
}
