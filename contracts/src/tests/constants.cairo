use zkramp::components::registry::interface::OffchainId;

pub fn REVTAG() -> ByteArray {
    "my wonderfull, incredible but also very long, revtag"
}

pub fn REVOLUT_ID() -> OffchainId {
    OffchainId::Revolut(REVTAG())
}
