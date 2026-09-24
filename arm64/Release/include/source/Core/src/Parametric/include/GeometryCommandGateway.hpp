#pragma once

#include "ParametricOrchestrator.hpp"
#include "ParametricModelRepository.hpp"
#include "ParametricModelTypes.hpp"
#include "TransactionAdapter.hpp"

namespace GPlatform::Parametric {

class GeometryCommandGateway {
public:
    static GeometryCommandGateway& instance();

    CommandResult execute(const CommandEnvelope& command);
    CommandResult query(const QueryEnvelope& query);

private:
    GeometryCommandGateway();

private:
    TransactionAdapter m_transactionAdapter;
    ParametricModelRepository m_repository;
    ParametricOrchestrator m_orchestrator;
};

} // namespace GPlatform::Parametric
